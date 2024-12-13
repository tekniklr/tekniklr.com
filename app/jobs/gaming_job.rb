class GamingJob < ApplicationJob
  
  def perform
    manual_items = get_recent_games
    psn_items = get_psn
    xbox_items = get_xbox
    steam_items = get_steam
    all_items = (manual_items + psn_items + xbox_items + steam_items).sort_by{|i| i.published}.reverse
    Rails.cache.write('gaming', all_items.sort_by{|i| i.published }.reverse.uniq{ |i| [i.title.downcase.gsub(/[^A-z0-9]/, '')] }[0..9])
  end
  
  private

  def get_recent_games
    Rails.logger.debug "Parsing manually entered games..."
    items = []
    RecentGame.first(12).each do |game|
      sort_time = Time.zone.local(game.started_playing.year, game.started_playing.month, game.started_playing.day, game.updated_at.hour, game.updated_at.min, game.updated_at.sec)
      items << {
        title:       game.name,
        platform:    game.platform,
        url:         game.url,
        published:   sort_time,
        thumb_url:   game.image.url(:thumb),
        image_url:   game.image.url(:default)
      }
    end
    return items
  end

  # using PSNProfiles.com
  def get_psn
    Rails.logger.debug "Fetching PSN trophies from PSNProfiles..."
    items = []
    begin
      games = make_request('https://psnprofiles.com/tekniklr', type: 'GET', params: { ajax: 1, completion: 'all', order: 'last-played', pf: 'all' }, content_type: 'text/html', user_agent: 'Mozilla/5.0')
      parsed_games = Nokogiri::HTML.parse(games.html)
      parsed_games.search('tr').select{|tr| tr.search('td').size > 3}.first(9).each do |game| # don't pull rows that are doing a colspan, because those rows probably don't contain games
        sleep 1 # avoid rate limiting
        game_info_link = game.search('a').first['href']
        game_info = make_request("https://psnprofiles.com#{game_info_link}", type: 'GET', params: { order: 'date' }, content_type: 'text/html', user_agent: 'Mozilla/5.0')
        parsed_game_info = Nokogiri::HTML.parse(game_info)
        game_title = parsed_game_info.search('h3').first.children.last.text
        newest_achievement = parsed_game_info.search('tr').css('.completed').last
        achievement_time = DateTime.parse("#{newest_achievement.search('td')[2].css('.typo-top-date').first.text} #{newest_achievement.search('td')[2].css('.typo-bottom-date').first.text}")
        image = store_local_copy(parsed_game_info.search('picture').css('.game').css('.lg').search('img').first['src'], "psn_#{game_title.gsub(/[^A-z]/, '')}")
        items << {
            platform:         'PlayStation',
            title:            game_title,
            achievement:      newest_achievement.search('td')[1].children[3].text.strip.gsub(/\.\z/, ''),
            achievement_time: achievement_time,
            published:        achievement_time,
            url:              "https://psnprofiles.com#{game_info_link}",
            image_url:        image,
            thumb_url:        image
          }
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing PSN activity via PSNProfiles", exception).deliver_now
    end
    return items
  end

  # using PlayStation API, which isn't officially documented but is reverse
  # engineer documented here:
  # https://andshrew.github.io/PlayStation-Trophies/#/APIv2?id=playstation-trophies-api-v2
  # see generate_psn_tokens(), etc., private methods below for more details
  def get_psn_api
    Rails.logger.debug "Fetching PSN achievements and games via PSN API.."
    @psn_token_cache = 'psn_token_cache'
    items =[]
    begin
      # authenticate
      token_data = Rails.cache.read(@psn_token_cache)
      process_psn_tokens(token_data) if token_data.present?

      # fetch 800 most recent trophies
      verify_psn_tokens
      psn_trophies = make_request("https://m.np.playstation.com/api/trophy/v1/users/#{Rails.application.credentials.playstation[:id]}/trophyTitles", type: 'GET', auth_token: @psn_token, params: { limit: 800 })
    rescue => exception
      ErrorMailer.background_error("fetching/parsing PSN achievements via API", exception).deliver_now
    end
    return items
  end

  # using the OpenXBL API at https://xbl.io/
  def get_xbox
    Rails.logger.debug "Fetching Xbox activity via OpenXBL API.."
    items = []
    begin
      games = make_request('https://xbl.io/api/v2/player/titleHistory', type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
      games.titles.select{|g| g.type == 'Game' }.first(9).each do |game|
        begin
          if game.devices.include?('Xbox360')
            achievements = make_request("https://xbl.io/api/v2/achievements/x360/#{Rails.application.credentials.xbox['id']}/title/#{game.titleId}", type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
            newest_achievement = achievements.achievements.select{|a| a.unlocked }.sort_by{|a| a.timeUnlocked}.last
            newest_achievement_time = newest_achievement ? Time.new(newest_achievement.timeUnlocked) : false
          else
            achievements = make_request("https://xbl.io/api/v2/achievements/player/#{Rails.application.credentials.xbox['id']}/#{game.titleId}", type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
            newest_achievement = achievements.achievements.select{|a| a.progressState == 'Achieved'}.sort_by{|a| a.progression.timeUnlocked}.last
            newest_achievement_time = newest_achievement ? Time.new(newest_achievement.progression.timeUnlocked) : false
          end
        rescue
          newest_achievement = false
          newest_achievement_time = false
        end
        image = store_local_copy(game.displayImage, "xbox_#{game.titleId}")
        items << {
            platform:         'Xbox',
            title:            game.name,
            achievement:      newest_achievement ? newest_achievement.name : false,
            achievement_time: newest_achievement_time ? newest_achievement_time : false,
            published:        Time.new(game.titleHistory.lastTimePlayed),
            image_url:        image,
            thumb_url:        image
          }
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Xbox activity via API", exception).deliver_now
    end
    return items
  end

  # using Steam API
  def get_steam
    Rails.logger.debug "Fetching steam achievements and games via Steam API.."
    items =[]
    begin
      steam_api_key = Rails.application.credentials.steam[:api_key]
      steam_id = Rails.application.credentials.steam[:id]
      steam_games = make_request('https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, format: 'json', include_appinfo: 'true', include_played_free_games: 'true' }).response
      recent_steam_games = steam_games.games.sort_by{|g| g.rtime_last_played}.reverse.first(9)
      recent_steam_games.each do |game|
        begin
          game_achievements = make_request('https://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, appid: game.appid, format: 'json' })
          newest_achievement = game_achievements.playerstats.has_key?('achievements') ? game_achievements.playerstats.achievements.select{|a| a.achieved == 1}.sort_by{|a| a.unlocktime}.last : false
        rescue
          # the steam API returns a `Net::HTTPBadRequest 400 Bad Request` error
          # for games that have no achievements
          # regardless of if the exception is that, or something else went
          # wrong, just assume there are no achievements this run
          newest_achievement = false
        end
        image = store_local_copy("https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/#{game.appid}/header.jpg", "steam_#{game.appid}")
        items << {
          platform:         'Steam',
          title:            game.name,
          achievement:      (newest_achievement && newest_achievement.has_key?('name')) ? newest_achievement.name : (newest_achievement ? newest_achievement.apiname : false),
          achievement_time: newest_achievement ? Time.at(newest_achievement.unlocktime) : false,
          published:        Time.at(game.rtime_last_played),
          url:              "https://store.steampowered.com/app/#{game.appid}/",
          image_url:        image,
          thumb_url:        image
        }
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Steam achievements via API", exception).deliver_now
    end
    return items
  end

  private

  # Generate tokens given an account and time specific npsso and shared
  # community client ID and auth. developed using community documentation from
  # https://andshrew.github.io/PlayStation-Trophies/#/APIv2?id=obtaining-an-authentication-token
  # and looking at other projects on github who use the same documentation
  # believe it or not, everyone on the internet uses the same client_id and
  # Basic auth token, AFAICT. I still put them in rails credentials because it
  # felt gross just leaving them here, even with them being public knowledge.
  # the npsso needs to be refreshed occassionally - get a new one by logging
  # into the playstation website at https://my.account.sony.com and visiting
  # https://ca.account.sony.com/api/v1/ssocookie
  def generate_psn_tokens
    # this first request returns a 302, which we do not want to follow but
    # instead want to get the code from the returned location
    auth_resp = make_request(
                  'https://ca.account.sony.com/api/authz/v3/oauth/authorize',
                  type: 'GET',
                  headers: {
                    Cookie: "npsso=#{Rails.application.credentials.playstation[:npsso]}"
                  },
                  params: {
                    access_type: 'offline',
                    client_id: Rails.application.credentials.playstation[:client_id],
                    response_type: 'code',
                    scope: 'psn:mobile.v2.core psn:clientapp',
                    redirect_uri: 'com.scee.psxandroid.scecompcall://redirect'
                  }
                )
    redirect_uri = URI.parse(auth_resp)
    redirect_params = Hash[URI.decode_www_form redirect_uri.query]

    # now, with the code from above, we can make a second request which should
    # provide an access token
    token_resp =  make_request(
                    'https://ca.account.sony.com/api/authz/v3/oauth/token',
                    type: 'POST',
                    body: {
                      code: redirect_params['code'],
                      redirect_uri: 'com.scee.psxandroid.scecompcall://redirect',
                      grant_type: 'authorization_code',
                      token_format: 'jwt'
                    },
                    content_type: 'application/x-www-form-urlencoded',
                    auth_type: 'Basic',
                    auth_token: Rails.application.credentials.playstation[:basic_auth]
                  )

    process_psn_tokens(token_resp)
    store_psn_token_data(token_resp)
  end

  def perform_psn_token_refresh
    response =  make_request(
                  "https://ca.account.sony.com/api/authz/v3/oauth/token",
                  type: 'POST',
                  headers: {
                    Cookie: "npsso=#{Rails.application.credentials.playstation[:npsso]}"
                  },
                  body: {
                    refresh_token: @psn_refresh_token,
                    grant_type: "refresh_token",
                    token_format: "jwt"
                  },
                  content_type: 'application/x-www-form-urlencoded',
                  auth_type: 'Basic',
                  auth_token: Rails.application.credentials.playstation[:basic_auth]
                )
    process_psn_tokens(response)
    store_psn_token_data(response)
  end

  def verify_psn_tokens
    if @psn_token.nil?
      generate_psn_tokens
    elsif @psn_token_expires_at < Time.now.utc + 60
      perform_psn_token_refresh
    end
  end

  def process_psn_tokens(response_body)
    @psn_token = response_body["accessToken"]
    @psn_refresh_token = response_body["refreshToken"]
    @psn_token_expires_at = Time.at(JSON.parse(Base64.decode64(response_body["accessJwt"].split(".")[1]))["exp"]).utc
  end

  def store_psn_token_data(data)
    Rails.cache.write(@psn_token_cache, data)
  end

end
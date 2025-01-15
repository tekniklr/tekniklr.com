class GamingJob < ApplicationJob
  
  def perform
    manual_items = get_recent_games
    psn_items = cache_if_present('gaming_psn', get_psn_rss)
    xbox_items = cache_if_present('gaming_xbox', get_xbox)
    steam_items = cache_if_present('gaming_steam', get_steam)
    all_items = (manual_items + psn_items + xbox_items + steam_items).sort_by{|i| i.published}.reverse.uniq{ |i| [normalize_title(i.title.downcase)] }
    Rails.cache.write('gaming', all_items[0..9])
  end
  
  private

  def get_recent_games
    Rails.logger.debug "Parsing manually entered games..."
    items = []
    RecentGame.sorted.first(12).each do |game|
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

  def update_recent_game(title, platform, time, image = false)
    Rails.logger.debug "Checking for RecentGame with #{title}..."
    matching_game = RecentGame.by_name(title).on_platform(platform).sorted.first
    if matching_game
      matching_game.update_attribute(:updated_at, time)
    else
      set_platform =  case platform
                      when 'psn'
                        RecentGame::PSN_PLATFORMS.first
                      when 'xbox'
                        RecentGame::XBOX_PLATFORMS.first
                      when 'steam'
                        RecentGame::STEAM_PLATFORMS.first
                      when 'switch'
                        RecentGame::NINTENDO_PLATFORMS.first
                      end
      matching_game = RecentGame.create(
        name:            title,
        platform:        set_platform,
        started_playing: time
      )
    end
    if image
      filename = "#{platform}_#{normalize_title(title)}"
      file_path = File.join(Rails.public_path, 'remote_cache', filename)
      if File.exist?(file_path) && !matching_game.image?
        file = File.open(file_path)
        matching_game.image = file
        file.close
        matching_game.save
      end
    end
  end

  def find_game_image(title, thumb = false, platform: false)
    Rails.logger.debug "Looking for cached or uploaded image for #{title}..."
    if platform
      filename = "#{platform}_#{normalize_title(title)}"
      file_path = File.join(Rails.public_path, 'remote_cache', filename)
      web_path = Rails.application.routes.url_helpers.root_path+"remote_cache/"+filename
      File.exist?(file_path) and return web_path
    end
    matching_game = RecentGame.by_name(title).with_image.sorted.first
    if matching_game && matching_game.image?
      return thumb ? matching_game.image.url(:thumb) : matching_game.image.url(:default)
    end
    ''
  end

  # using truetrophies which seems to be one of the only reliable ways to turn 
  # PSN trophies into an RSS feed...
  def get_psn_rss
    Rails.logger.debug "Fetching PSN trophies from truetrophies..."
    rss_items = get_xml('https://www.truetrophies.com/friendfeedrss.aspx?gamerid=26130', 'gaming_expiry')
    items = []
    rss_items.each do |item|
      item.title.match?(/tekniklr (started|completed)/) and next
      item.title.match(/tekniklr won the (.*) (trophy|achievement) in (.*)\z/)
      if ($1.blank? || $2.blank? || $3.blank?)
        puts "Couldn't parse an achievement, type, or game title from \"#{item.title}\"! Skipping."
        next
      end
      achievement = $1
      title = $3
      title.gsub!(/ Trophies/, '')
      update_recent_game(title, 'psn', item.published)
      items << {
            platform:         'PlayStation',
            title:            title,
            achievement:      achievement,
            achievement_time: item.published,
            published:        item.published,
            url:              item.url,
            image_url:        find_game_image(title, platform: 'psn'),
            thumb_url:        find_game_image(title, true, platform: 'psn')
          }
    end
    return items
  end

  # using PSNProfiles.com - unfortunately, while this works locally DreamHost
  # is blocked
  def get_psn_profiles
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
        image = store_local_copy(parsed_game_info.search('picture').css('.game').css('.lg').search('img').first['src'], 'psn', normalize_title(game_title))
        update_recent_game(title, 'psn', achievement_time)
        items << {
            platform:         'PlayStation',
            title:            game_title,
            achievement:      newest_achievement.search('td')[1].children[3].text.strip.gsub(/\.\z/, ''),
            achievement_time: achievement_time,
            published:        achievement_time,
            url:              "https://psnprofiles.com#{game_info_link}",
            image_url:        image ? image : find_game_image(game_title),
            thumb_url:        image ? image : find_game_image(game_title, true)
          }
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing PSN activity via PSNProfiles", exception).deliver_now
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
        title = game.name.gsub(/ - Windows Edition/, '')
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
        image = store_local_copy(game.displayImage, 'xbox', title)
        time = Time.new(game.titleHistory.lastTimePlayed)
        update_recent_game(title, 'xbox', time, image)
        items << {
            platform:         'Xbox',
            title:            title,
            achievement:      newest_achievement ? newest_achievement.name : false,
            achievement_time: newest_achievement_time ? newest_achievement_time : false,
            published:        time,
            image_url:        image ? image : find_game_image(title),
            thumb_url:        image ? image : find_game_image(title, true)
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
        title = game.name
        image = store_local_copy("https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/#{game.appid}/header.jpg", 'steam', title)
        time = Time.at(game.rtime_last_played)
        update_recent_game(title, 'steam', time, image)
        items << {
          platform:         'Steam',
          title:            title,
          achievement:      (newest_achievement && newest_achievement.has_key?('name')) ? newest_achievement.name : (newest_achievement ? newest_achievement.apiname : false),
          achievement_time: newest_achievement ? Time.at(newest_achievement.unlocktime) : false,
          published:        time,
          url:              "https://store.steampowered.com/app/#{game.appid}/",
          image_url:        image ? image : find_game_image(game.name),
          thumb_url:        image ? image : find_game_image(game.name, true)
        }
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Steam achievements via API", exception).deliver_now
    end
    return items
  end

  # using Nintendo API
  def get_nintendo
    Rails.logger.debug "Fetching game activity via Nintendo API.."
    items =[]
    begin
      # to get new codes:
      # 1. log out of the iOS Switch app
      # 2. when logging back in, copy the authorization page (that shows
      #    account) to a Notes app quick note
      # 3. open the link from that note in Notes app on a computer, and copy
      #    the url at the authorize button (it will start with
      #    `npf71b963c1b7b6d119://`)
      # that URL contains these parameters:
      #    session_token_code (session_token_code)
      #    state (session_token_code_verifier)
      #    session_state
      # also, the protocol (npf71b963c1b7b6d119://) has the client_id, after
      # the `npf`
      client_id = Rails.application.credentials.nintendo[:client_id]
      session_token_code = Rails.application.credentials.nintendo[:session_token_code]
      session_token_code_verifier = Rails.application.credentials.nintendo[:session_token_code_verifier]

      user_agent_version = 'unknown' # see https://github.com/frozenpandaman/splatnet2statink/commits/master

      session_token_resp =  make_request(
                              'https://accounts.nintendo.com/connect/1.0.0/api/session_token',
                              type: 'POST',
                              content_type: 'application/x-www-form-urlencoded',
                              user_agent: "OnlineLounge/#{user_agent_version} NASDKAPI Android",
                              headers: {
                                'X-Platform': 'Android',
                                'X-ProductVersion': user_agent_version,
                              },
                              body: {
                                client_id: client_id,
                                session_token_code: session_token_code,
                                session_token_code_verifier: session_token_code_verifier
                              }
                            )
      session_token = session_token_resp.session_token

      api_token_resp =  make_request(
                          'https://accounts.nintendo.com/connect/1.0.0/api/token',
                          type: 'POST',
                          content_type: 'application/json; charset=utf-8',
                          user_agent: "com.nintendo.znca/#{user_agent_version} (Android/7.1.2)",
                          headers: {
                            'X-Platform': 'Android',
                            'X-ProductVersion': user_agent_version
                          },
                          body: {
                            client_id: client_id,
                            grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer-session-token',
                            session_token: session_token
                          }
                        )

    rescue => exception
      ErrorMailer.background_error("fetching/parsing Nintendo games via API", exception).deliver_now
    end
    return items
  end

end
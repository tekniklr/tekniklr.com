class GamingJob < ApplicationJob
  
  def perform
    defer_retry('fetch_nintendo', 12) { get_nintendo }
    defer_retry('fetch_psn', 24) { get_psn }
    defer_retry('fetch_steam', 12) { get_steam }
    defer_retry('fetch_xbox', 6) { get_xbox }
    recent_games = get_recent_games
    Rails.cache.write('gaming', recent_games[0..9])
  end
  
  private

  def get_recent_games
    Rails.logger.debug "Parsing RecentGames..."
    items = []
    RecentGame.visible.sorted.first(12).each do |game|
      items << {
        title:            game.name,
        platform:         game.platform,
        url:              game.url,
        published:        game.last_played,
        thumb_url:        game.image? ? game.image.url(:thumb) : "game-controller.png",
        image_url:        game.image? ? game.image.url(:default) : "game-controller.png",
        achievement:      game.achievement_name ? game.achievement_name : false,
        achievement_time: game.achievement_time ? game.achievement_time : false,
        achievement_desc: game.achievement_desc ? game.achievement_desc : false
      }
    end
    return items
  end

  def matching_recent_game(title, platform: false, image_only: false)
    Rails.logger.debug "Looking for recent game #{title}#{platform ? ' on '+platform : ''}..."
    matching_game = RecentGame.by_name(title)
    matching_game = matching_game.on_platform(platform) if platform
    matching_game = matching_game.with_image if image_only
    matching_game.sorted.first
  end

  def update_recent_game(matching_game: false, details: {title: title, platform: platform, time: time, image: false, url: false, achievement: false})
    if matching_game
      Rails.logger.debug "Updating RecentGame #{matching_game.name}..."
    else
      Rails.logger.debug "Creating RecentGame #{details.title}..."
      set_platform =  case details.platform
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
          name:            details.title,
          platform:        set_platform,
          last_played:     details.time
        )
    end
    if matching_game.last_played.to_i < details.time.to_i
      Rails.logger.debug "Updating last_played for RecentGame #{details.title}..."
      matching_game.update_attribute(:last_played, details.time)
    end
    if details.has_key?(:image) && !details.image.blank? && (!matching_game.image? || !File.exist?(matching_game.image.path))
      filename = "#{details.platform}_#{normalize_title(details.title)}"
      file_path = File.join(Rails.public_path, 'remote_cache', filename)
      if File.exist?(file_path)
        Rails.logger.debug "Updating RecentGame image for #{matching_game.name}..."
        file = File.open(file_path)
        matching_game.image = file
        file.close
        matching_game.save
      end
    end
    if details.has_key?(:achievement) && !details.achievement.blank? && ((details.achievement.name != matching_game.achievement_name) || (!details.achievement.desc.blank? && matching_game.achievement_desc.blank?))
      Rails.logger.debug "Updating Achievement: #{details.achievement.name}..."
      matching_game.achievement_name = details.achievement.name
      matching_game.achievement_time = details.achievement.time ? details.achievement.time : nil
      matching_game.achievement_desc = details.achievement.desc ? details.achievement.desc : nil
      matching_game.save
    end
  end

  def find_game_image(game, thumb: false)
    game or return false
    Rails.logger.debug "Looking for immage for RecentGame #{game.name}..."
    if game.image? && File.exist?(game.image.path)
      Rails.logger.debug "Found game image!"
      return thumb ? game.image.url(:thumb) : game.image.url(:default)
    end
    false
  end

  def get_psn
    Rails.logger.debug "Fetching PSN activity from PSN API..."
    account_id = Rails.application.credentials.psn['account_id']
    npsso = Rails.application.credentials.psn['npsso']

    auth =  make_request(
              'https://ca.account.sony.com/api/authz/v3/oauth/authorize',
              type: 'GET',
              params: {
                access_type:   'offline',
                client_id:     '09515159-7237-4370-9b40-3806e67c0891',
                response_type: 'code',
                scope:         'psn:mobile.v2.core psn:clientapp',
                redirect_uri:  'com.scee.psxandroid.scecompcall://redirect'
              },
              headers: {
                Cookie:        "npsso=#{npsso}"
              }
            )
    auth_uri = URI.parse(auth)
    auth_params = {}
    auth_uri.query.split('&').each do |param|
      key,value = param.split('=')
      auth_params[key] = value
    end
    unless auth_params.has_key?('code')
      message = "No 'code' parameter returned after trying to authenticate - probably need to refresh NPSSO."
      message += "\n\n\t1. In a private browser window, log into https://store.playstation.com"
      message += "\n\t2. After logging in, in the same window, go to https://ca.account.sony.com/api/v1/ssocookie"
      message += "\n\t3. Update rails credentials with new npsso"
      message += "\n\nSee https://andshrew.github.io/PlayStation-Trophies/#/APIv2?id=obtaining-an-authentication-token for more details"
      raise message
    end
    token = make_request(
              'https://ca.account.sony.com/api/authz/v3/oauth/token',
              type: 'POST',
              body: {
                code:         auth_params['code'],
                redirect_uri: 'com.scee.psxandroid.scecompcall://redirect',
                grant_type:   'authorization_code',
                token_format: 'jwt'
              },
              url_encoded:    true,
              auth_type:      'Basic',
              auth_token:     'MDk1MTUxNTktNzIzNy00MzcwLTliNDAtMzgwNmU2N2MwODkxOnVjUGprYTV0bnRCMktxc1A='
            )
    secure_token = token.access_token

    games = make_request(
                        "https://m.np.playstation.com/api/gamelist/v2/users/#{account_id}/titles",
                        type: 'GET',
                        auth_token:  secure_token,
                        params: {
                          limit:     9
                        }
                      )
    games.titles.first(9).each do |game|
      title = game.name
      time = Time.new(game.lastPlayedDateTime)

      matching_game = matching_recent_game(title, platform: 'psn')

      image = find_game_image(matching_game)
      if !image
        image = store_local_copy(game.imageUrl, 'psn', title)
      end

      # since the last played time is when a game was last started, any
      # trophies earned during that session won't be looked up. so, look up
      # trophies for all new games and all games where the last played is
      # within the last 24 hours
      if matching_game.blank? || (Time.now-24.hours < time)
        achievement = false

        # this request is mostly useless, as it just returns details for the
        # rarest trophy, but we do need to get the npCommunicationId for the
        # game to get trophy details
        rarest_trophy =  make_request(
                                "https://m.np.playstation.com/api/trophy/v1/users/#{account_id}/titles/trophyTitles?npTitleIds=#{game.titleId}",
                                type: 'GET',
                                auth_token: secure_token
                              )
        if rarest_trophy && !rarest_trophy.titles.first.trophyTitles.empty?
          ps5_game = (game.category == 'ps5_native_game')
          np_communication_id = rarest_trophy.titles.first.trophyTitles.first.npCommunicationId
          params = {}
          unless ps5_game
            params['npServiceName'] = 'trophy'
          end
          all_game_trophies = make_request(
                            "https://m.np.playstation.com/api/trophy/v1/users/#{account_id}/npCommunicationIds/#{np_communication_id}/trophyGroups/all/trophies",
                            type: 'GET',
                            params: params,
                            auth_token: secure_token
                          )
          earned_trophies = all_game_trophies.trophies.select{|t| t.earned}
          newest_earned_trophy = false
          trophy_time = false
          unless earned_trophies.empty?
            # sometimes when trophies are awarded in bulk many will have the
            # same timestamp, if that happens, return the rarest trophy awarded
            # at that timestamp
            trophy_timestamp = earned_trophies.sort_by{|t| Time.new(t['earnedDateTime']).to_i}.last.earnedDateTime
            newest_earned_trophy = earned_trophies.select{|t| t['earnedDateTime'] == trophy_timestamp}.sort_by{|t| t['trophyEarnedRate'].to_i}.first
            trophy_time = Time.new(trophy_timestamp)
          end
          if trophy_time && (matching_game.blank? || (trophy_time.to_i > matching_game.last_played.to_i))
            params = {}
            unless ps5_game
              params['npServiceName'] = 'trophy'
            end
            all_trophy_details =  make_request(
                                    "https://m.np.playstation.com/api/trophy/v1/npCommunicationIds/#{np_communication_id}/trophyGroups/all/trophies",
                                    type: 'GET',
                                    params: params,
                                    auth_token: secure_token
                                  )
            trophy_details = all_trophy_details.trophies.select{|t| t.trophyId == newest_earned_trophy.trophyId}.first
            achievement = {
              name: trophy_details.trophyName,
              time: trophy_time,
              desc: trophy_details.trophyDetail
            }
          end
        end

        update_recent_game(matching_game: matching_game, details: { title: title, platform: 'psn', time: time, image: image, achievement: achievement })
      end
    end
    clear_local_copies('psn')
  end

  # using the OpenXBL API at https://xbl.io/
  def get_xbox
    Rails.logger.debug "Fetching Xbox activity via OpenXBL API.."
    games = make_request('https://xbl.io/api/v2/player/titleHistory', type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
    games.titles.select{|g| g.type == 'Game' }.first(9).each do |game|
      title = game.name.gsub(/ - Windows Edition/, '')
      time = Time.new(game.titleHistory.lastTimePlayed)

      matching_game = matching_recent_game(title, platform: 'xbox')

      image = find_game_image(matching_game)
      if !image
        image = store_local_copy(game.displayImage, 'xbox', title)
      end

      # previously this compared matching_game.last_played to the time last
      # played in the API, but depending on when the API was last queried and
      # when an achievement was last earned it was sometimes possible to not
      # query/update acheivements when they should be. so, look up achievements
      # for all new games and all games played within the last 24 hours
      if matching_game.blank? || (Time.now-24.hours < time)
        achievement = false
        newest_achievement = false
        newest_achievement_time = false

        if game.devices.include?('Xbox360')
          achievements = make_request("https://xbl.io/api/v2/achievements/x360/#{Rails.application.credentials.xbox['id']}/title/#{game.titleId}", type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
          newest_achievement = achievements.achievements.select{|a| a.unlocked }.sort_by{|a| a.timeUnlocked}.last
          newest_achievement_time = newest_achievement ? Time.new(newest_achievement.timeUnlocked) : false
        else
          achievements = make_request("https://xbl.io/api/v2/achievements/player/#{Rails.application.credentials.xbox['id']}/#{game.titleId}", type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
          newest_achievement = achievements.achievements.select{|a| a.progressState == 'Achieved'}.sort_by{|a| a.progression.timeUnlocked}.last
          newest_achievement_time = newest_achievement ? Time.new(newest_achievement.progression.timeUnlocked) : false
        end

        if newest_achievement
          achievement = {
            name: newest_achievement ? newest_achievement.name : false,
            time: newest_achievement_time ? newest_achievement_time : false,
            desc: newest_achievement ? newest_achievement.description : false
          }
        end

        update_recent_game(matching_game: matching_game, details: { title: title, platform: 'xbox', time: time, image: image, achievement: achievement })
      end
    end
    clear_local_copies('xbox')
  end

  # using Steam API
  def get_steam
    Rails.logger.debug "Fetching steam achievements and games via Steam API.."
    steam_api_key = Rails.application.credentials.steam[:api_key]
    steam_id = Rails.application.credentials.steam[:id]
    steam_games = make_request('https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, format: 'json', include_appinfo: 'true', include_played_free_games: 'true' }).response
    recent_steam_games = steam_games.games.sort_by{|g| g.rtime_last_played}.reverse.first(9)
    recent_steam_games.each do |game|
      title = game.name
      time = Time.at(game.rtime_last_played)
      url = "https://store.steampowered.com/app/#{game.appid}/"

      matching_game = matching_recent_game(title, platform: 'steam')

      image = find_game_image(matching_game)
      if !image
        image = store_local_copy("https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/#{game.appid}/header.jpg", 'steam', title)
      end

      # previously this compared matching_game.last_played to the time last
      # played in the API, but depending on when the API was last queried and
      # when an achievement was last earned it was sometimes possible to not
      # query/update acheivements when they should be. so, look up achievements
      # for all new games and all games played within the last 24 hours
      if matching_game.blank? || (Time.now-24.hours < time)
        achievement = false

        game_achievements = make_request('https://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, appid: game.appid, format: 'json' })
        newest_achievement = game_achievements.playerstats.has_key?('achievements') ? game_achievements.playerstats.achievements.select{|a| a.achieved == 1}.sort_by{|a| a.unlocktime}.last : false

        if newest_achievement
          achievement = {
            name: (newest_achievement && newest_achievement.has_key?('name')) ? newest_achievement.name : (newest_achievement ? newest_achievement.apiname : false),
            time: newest_achievement ? Time.at(newest_achievement.unlocktime) : false,
            desc: false
          }
        end

        update_recent_game(matching_game: matching_game, details: { title: title, platform: 'steam', time: time, image: image, achievement: achievement })
      end
    end
    clear_local_copies('steam')
  end

  # using Nintendo API
  def get_nintendo
    Rails.logger.debug "Fetching game activity via Nintendo API.."
    access_token =  make_request(
                            'https://accounts.nintendo.com/connect/1.0.0/api/token',
                            type: 'POST',
                            body: {
                              client_id: Rails.application.credentials.nintendo[:client_id],
                              session_token: Rails.application.credentials.nintendo[:session_token],
                              grant_type: Rails.application.credentials.nintendo[:grant_type]
                            },
                            user_agent: 'Znma/2.3.0 (com.nintendo.znma; build:600; iOS 26.1.0) NASDK/2.3.0',
                            headers: {
                              'Accept': 'application/json',
                              'Accept-Encoding': 'gzip, deflate, br',
                              'Accept-Language': 'en-US;q=1.0'
                            }
                          )
    daily_summary = make_request(
                          'https://app.lp1.znma.srv.nintendo.net/v2/actions/playSummary/fetchDailySummaries',
                          type: 'GET',
                          params: {
                            deviceId: Rails.application.credentials.nintendo[:device_id]
                          },
                          auth_token: access_token.id_token,
                          user_agent: 'znma_ios/2.3.0 (com.nintendo.znma; build:600; iOS Version 26.1 (Build 23B85)',
                          headers: {
                            'X-Moon-App-Internal-Version': '600',
                            'X-Moon-Os': 'IOS',
                            'X-Moon-Os-Version': '26.1',
                            'Accept': '*/*',
                            'Accept-Encoding': 'gzip, deflate, br',
                            'Accept-Language': 'en-US,en;q=0.9'
                          }
                        )
    players = daily_summary.dailySummaries.first.players # only looking at today's summaries
    me = players.select{|p| p.profile.playerId == Rails.application.credentials.nintendo[:player_id]}.first
    if me # if I have played today
      me.playedGames.each_with_index do |item, index|
        title = item.meta.title
        time = Time.at(daily_summary.lastUpdatedAt) # the new API doesn't report last played time anymore, this is probably as close as we will get
        url = item.meta.shopUri

        matching_game = matching_recent_game(title, platform: 'switch')

        image = find_game_image(matching_game)
        if !image
          image = store_local_copy(item.meta.imageUri.large, 'switch', title)
        end

        if matching_game.blank? || ((Time.now-24.hours < daily_summary.dailySummaries.first.date.to_time) && (matching_game.last_played.end_of_day < time)) # since we don't have a precise last played time, only update RecentGame if it has not yet been updated today
          update_recent_game(matching_game: matching_game, details: { title: title, platform: 'switch', time: time, image: image, url: url })
        end
      end
    end
    clear_local_copies('switch')
  end

end
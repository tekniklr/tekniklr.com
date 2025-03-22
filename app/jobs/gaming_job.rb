class GamingJob < ApplicationJob
  
  def perform
    get_nintendo
    get_psn
    get_steam
    get_xbox
    recent_games = get_recent_games
    Rails.cache.write('gaming', recent_games[0..9])
  end
  
  private

  def get_recent_games
    Rails.logger.debug "Parsing RecentGames..."
    items = []
    RecentGame.sorted.first(12).each do |game|
      items << {
        title:            game.name,
        platform:         game.platform,
        url:              game.url,
        published:        game.started_playing.beginning_of_day,
        thumb_url:        game.image.url(:thumb),
        image_url:        game.image.url(:default),
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

  def update_recent_game(title, platform, time, image: false, url: false, achievement: false, create: true)
    Rails.logger.debug "Checking RecentGame #{title}..."
    matching_game = matching_recent_game(title, platform: platform)
    if matching_game && (matching_game.started_playing.to_date < time.to_date)
      Rails.logger.debug "Updating started_playing for RecentGame #{title}..."
      matching_game.update_attribute(:started_playing, time)
    elsif matching_game.blank?
      Rails.logger.debug "No game found matching #{title}!"
      if create
        Rails.logger.debug "Creating RecentGame #{title}..."
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
      else
        Rails.logger.debug "'create' is false. Exiting."
        return
      end
    end
    if image && (!matching_game.image? || !File.exist?(matching_game.image.path))
      filename = "#{platform}_#{normalize_title(title)}"
      file_path = File.join(Rails.public_path, 'remote_cache', filename)
      if File.exist?(file_path)
        Rails.logger.debug "Updating RecentGame image for #{title}..."
        file = File.open(file_path)
        matching_game.image = file
        file.close
        matching_game.save
      end
    end
    if achievement && ((achievement.name != matching_game.achievement_name) || (!achievement.desc.blank? && matching_game.achievement_desc.blank?))
      Rails.logger.debug "Updating Achievement: #{achievement.name}..."
      matching_game.achievement_name = achievement.name
      matching_game.achievement_time = achievement.time ? achievement.time : nil
      matching_game.achievement_desc = achievement.desc ? achievement.desc : nil
      matching_game.save
    end
  end

  def find_game_image(title, thumb: false, platform: false)
    Rails.logger.debug "Looking for existing image for #{title}#{platform ? ' on '+platform : ''}..."
    matching_game = matching_recent_game(title, platform: platform, image_only: true)
    if matching_game && matching_game.image? && File.exist?(matching_game.image.path)
      Rails.logger.debug "Found matching game, with image!"
      return thumb ? matching_game.image.url(:thumb) : matching_game.image.url(:default)
    end
    false
  end

  def get_psn
    Rails.logger.debug "Fetching PSN activity from PSN API..."
    begin
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
      token = make_request(
                'https://ca.account.sony.com/api/authz/v3/oauth/token',
                type: 'POST',
                body: {
                  code:         auth_params['code'],
                  redirect_uri: 'com.scee.psxandroid.scecompcall://redirect',
                  grant_type:   'authorization_code',
                  token_format: 'jwt'
                },
                content_type:   'application/x-www-form-urlencoded',
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

        image = find_game_image(title, platform: 'psn')
        if !image
          image = store_local_copy(game.imageUrl, 'psn', title)
        end

        achievement = false
        newest_achievement = false
        matching_game = matching_recent_game(title, platform: 'psn')
        begin
          if matching_game.blank? || (matching_game.started_playing < time)
            # this request is mostly useless, as it just returns details for the
            # rarest trophy, but we do need to get the npCommunicationId for the
            # game
            newest_achievement =  make_request(
                                    "https://m.np.playstation.com/api/trophy/v1/users/#{account_id}/titles/trophyTitles?npTitleIds=#{game.titleId}",
                                    type: 'GET',
                                    auth_token: secure_token
                                  )
          end
          if newest_achievement
            ps5_game = (game.category == 'ps5_native_game')
            np_communication_id = newest_achievement.titles.first.trophyTitles.first.npCommunicationId
            game_trophies = make_request(
                              "https://m.np.playstation.com/api/trophy/v1/users/#{account_id}/npCommunicationIds/#{np_communication_id}/trophyGroups/all/#{ps5_game ? '' : 'npServiceName/trophy/'}trophies",
                              type: 'GET',
                              auth_token: secure_token
                            )
            newest_trophy = game_trophies.trophies.select{|t| t.earned}.sort_by{|t| Time.new(t['earnedDateTime']).to_i}.last
            all_trophy_details =  make_request(
                                    "https://m.np.playstation.com/api/trophy/v1/npCommunicationIds/#{np_communication_id}/trophyGroups/all/trophies",
                                    type: 'GET',
                                    auth_token: secure_token
                                  )
            trophy_details = all_trophy_details.trophies.select{|t| t.trophyId == newest_trophy.trophyId}.first
            achievement = {
              name: trophy_details.trophyName,
              time: Time.new(newest_trophy.earnedDateTime),
              desc: trophy_details.trophyDetail
            }
          end
        end

        update_recent_game(title, 'psn', time, image: image, achievement: achievement)
      end

    rescue => exception
      ErrorMailer.background_error("fetching/parsing PSN games via API", exception).deliver_now
    end
    clear_local_copies('psn')
  end

  # using the OpenXBL API at https://xbl.io/
  def get_xbox
    Rails.logger.debug "Fetching Xbox activity via OpenXBL API.."
    begin
      games = make_request('https://xbl.io/api/v2/player/titleHistory', type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
      games.titles.select{|g| g.type == 'Game' }.first(9).each do |game|
        title = game.name.gsub(/ - Windows Edition/, '')
        time = Time.new(game.titleHistory.lastTimePlayed)

        image = find_game_image(title, platform: 'xbox')
        if !image
          image = store_local_copy(game.displayImage, 'xbox', title)
        end

        achievement = false
        newest_achievement = false
        newest_achievement_time = false
        matching_game = matching_recent_game(title, platform: 'xbox')
        if matching_game.blank? || (matching_game.started_playing < time)
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
          end
        end
        if newest_achievement
          achievement = {
            name: newest_achievement ? newest_achievement.name : false,
            time: newest_achievement_time ? newest_achievement_time : false,
            desc: newest_achievement ? newest_achievement.description : false
          }
        end

        update_recent_game(title, 'xbox', time, image: image, achievement: achievement)
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Xbox activity via API", exception).deliver_now
    end
    clear_local_copies('xbox')
  end

  # using Steam API
  def get_steam
    Rails.logger.debug "Fetching steam achievements and games via Steam API.."
    begin
      steam_api_key = Rails.application.credentials.steam[:api_key]
      steam_id = Rails.application.credentials.steam[:id]
      steam_games = make_request('https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, format: 'json', include_appinfo: 'true', include_played_free_games: 'true' }).response
      recent_steam_games = steam_games.games.sort_by{|g| g.rtime_last_played}.reverse.first(9)
      recent_steam_games.each do |game|
        title = game.name
        time = Time.at(game.rtime_last_played)
        url = "https://store.steampowered.com/app/#{game.appid}/"

        image = find_game_image(title, platform: 'steam')
        if !image
          image = store_local_copy("https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/#{game.appid}/header.jpg", 'steam', title)
        end

        achievement = false
        newest_achievement = false
        matching_game = matching_recent_game(title, platform: 'steam')
        if matching_game.blank? || (matching_game.started_playing < time)
          begin
            game_achievements = make_request('https://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, appid: game.appid, format: 'json' })
            newest_achievement = game_achievements.playerstats.has_key?('achievements') ? game_achievements.playerstats.achievements.select{|a| a.achieved == 1}.sort_by{|a| a.unlocktime}.last : false
          end
        end
        if newest_achievement
          achievement = {
            name: (newest_achievement && newest_achievement.has_key?('name')) ? newest_achievement.name : (newest_achievement ? newest_achievement.apiname : false),
            time: newest_achievement ? Time.at(newest_achievement.unlocktime) : false,
            desc: false
          }
        end

        update_recent_game(title, 'steam', time, image: image, achievement: achievement)
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Steam achievements via API", exception).deliver_now
    end
    clear_local_copies('steam')
  end

  # using Nintendo API
  def get_nintendo
    Rails.logger.debug "Fetching game activity via Nintendo API.."
    begin
      access_token =  make_request(
                              'https://accounts.nintendo.com/connect/1.0.0/api/token',
                              type: 'POST',
                              body: {
                                client_id: Rails.application.credentials.nintendo[:client_id],
                                session_token: Rails.application.credentials.nintendo[:session_token],
                                grant_type: Rails.application.credentials.nintendo[:grant_type]
                              }
                            )
      daily_summary = make_request(
                          "https://api-lp1.pctl.srv.nintendo.net/moon/v1/devices/#{Rails.application.credentials.nintendo[:device_id]}/daily_summaries",
                            type: 'GET',
                            auth_token: access_token.access_token,
                            headers: {
                              'x-moon-os-language': 'en-US',
                              'x-moon-app-language': 'en-US',
                              'x-moon-app-internal-version': '361',
                              'x-moon-app-display-version': '1.22.0',
                              'x-moon-app-id': 'com.nintendo.znma',
                              'x-moon-os': 'IOS',
                              'x-moon-os-version': '18.2.1',
                              'x-moon-model': 'iPhone17,1',
                              'accept-encoding': 'gzip;q=1.0, compress;q=0.5',
                              'accept-language': 'en-US;q=1.0',
                              'user-agent': 'moon_ios/1.22.0 (com.nintendo.znma; build:361; iOS 18.2.1) Alamofire/5.9.0',
                              'x-moon-timezone': 'America/Los_Angeles',
                              'x-moon-smart-device-id': Rails.application.credentials.nintendo[:smart_device_id]
                            }
                          )
      daily_summary.items.first.playedApps.each_with_index do |item, index|
        title = item.title
        image = find_game_image(title, platform: 'switch')
        if !image
          image = store_local_copy(item.imageUri.medium, 'switch', title)
        end
        time = (index == 0) ? Time.at(daily_summary.items.first.lastPlayedAt) : item.firstPlayDate.to_date.beginning_of_day
        url = item.shopUri
        update_recent_game(title, 'switch', time, image: image, url: url)
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Nintendo games via API", exception).deliver_now
    end
    clear_local_copies('switch')
  end

end
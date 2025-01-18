class GamingJob < ApplicationJob
  
  def perform
    psn_items = cache_if_present('gaming_psn', get_psn)
    xbox_items = cache_if_present('gaming_xbox', get_xbox)
    steam_items = cache_if_present('gaming_steam', get_steam)
    nintendo_items = cache_if_present('gaming_nintendo', get_nintendo)
    manual_items = get_recent_games
    all_items = (manual_items + psn_items + xbox_items + steam_items + nintendo_items).sort_by{|i| i.published}.reverse.uniq{ |i| [normalize_title(i.title)] }
    Rails.cache.write('gaming', all_items[0..9])
  end
  
  private

  def get_recent_games
    Rails.logger.debug "Parsing manually entered games..."
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

  def update_recent_game(title, platform, time, image: false, url: false, achievement: false, create: true)
    Rails.logger.debug "Checking RecentGame #{title}..."
    matching_game = RecentGame.by_name(title).on_platform(platform).sorted.first
    if matching_game && (matching_game.started_playing.to_date < time.to_date)
      Rails.logger.debug "Updating started_playing for RecentGame #{title}..."
      matching_game.update_attribute(:started_playing, time)
    elsif matching_game.blank?
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
        return
      end
    end
    if image && !matching_game.image?
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
    if achievement && (achievement.name != matching_game.achievement_name)
      matching_game.achievement_name = achievement.name
      matching_game.achievement_time = achievement.time ? achievement.time : nil
      matching_game.achievement_desc = achievement.desc ? achievement.desc : nil
      matching_game.save
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

  # scrapes PS-Timetracker for PSN activity, and fetches truetrophies RSS for
  # trophies and game images
  def get_psn
    Rails.logger.debug "Fetching PSN activity from PSN-timetracker..."
    last_played_times = {}
    games = make_request('https://ps-timetracker.com/profile/tekniklr', type: 'GET', content_type: 'text/html', user_agent: 'Mozilla/5.0')
    parsed_games = Nokogiri::HTML.parse(games)
    parsed_games.search('table').css('#user-table').search('tbody').search('tr').each do |game|
      title = game.search('td')[2].text
      last_played_times[normalize_title(title)] = {
        time:  Time.at(game.search('td')[7].attr('data-sort').to_i),
        title: title
      }
    end

    Rails.logger.debug "Fetching PSN trophies from truetrophies..."
    items = []
    rss_items = get_xml('https://www.truetrophies.com/friendfeedrss.aspx?gamerid=26130', 'gaming_expiry')
    rss_items.each do |item|
      item.title.match?(/tekniklr (started|completed)/) and next
      item.title.match(/tekniklr won the (.*) (trophy|achievement) in (.*)\z/)
      if ($1.blank? || $2.blank? || $3.blank?)
        puts "Couldn't parse an achievement, type, or game title from \"#{item.title}\"! Skipping."
        next
      end
      achievement_name = $1
      title = $3
      title.gsub!(/ Trophies/, '')
      image = find_game_image(title, platform: 'psn')
      if image.blank?
        game_info = make_request(item.url, type: 'GET', content_type: 'text/html', user_agent: 'Mozilla/5.0')
        parsed_game_info = Nokogiri::HTML.parse(game_info)
        image_url = "https://www.truetrophies.com"+parsed_game_info.css('.info').search('picture').search('source').last['srcset'].split(',').last.split(' ').first
        image = store_local_copy(image_url, 'psn', normalize_title(title))
      end
      if achievement_name
        achievement = {
          name: achievement_name,
          time: item.published,
          desc: false
        }
      end
      last_played = item.published
      if last_played_times.has_key?(normalize_title(title))
        last_played = last_played_times[normalize_title(title)].time
        last_played_times.delete(normalize_title(title))
      end
      update_recent_game(title, 'psn', last_played, image: image, achievement: achievement)
      items << {
            platform:         'PlayStation',
            title:            title,
            achievement:      achievement ? achievement.name : false,
            achievement_time: achievement ? achievement.time : false,
            published:        last_played,
            url:              item.url,
            image_url:        image,
            thumb_url:        find_game_image(title, true, platform: 'psn')
          }

      # any games that have been played recently but lack a recent trophy (thus
      # they remain in the hash) need to have their last played time updated in
      # RecentGames; don't create one though, as there won't be a game image
      # available until the TrueTrophies RSS picks up an achievement
      last_played_times.each do |game, values|
        update_recent_game(values.title, 'psn', values.time, create: false)
      end
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
        if newest_achievement
          achievement = {
            name: newest_achievement ? newest_achievement.name : false,
            time: newest_achievement_time ? newest_achievement_time : false,
            desc: newest_achievement ? newest_achievement.description : false
          }
        end
        update_recent_game(title, 'xbox', time, image: image, achievement: achievement)
        items << {
            platform:         'Xbox',
            title:            title,
            achievement:      achievement ? achievement.name : false,
            achievement_time: achievement ? achievement.time : false,
            achievement_desc: achievement ? achievement.desc : false,
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
        url = "https://store.steampowered.com/app/#{game.appid}/"
        if newest_achievement
          achievement = {
            name: (newest_achievement && newest_achievement.has_key?('name')) ? newest_achievement.name : (newest_achievement ? newest_achievement.apiname : false),
            time: newest_achievement ? Time.at(newest_achievement.unlocktime) : false,
            desc: false
          }
        end
        update_recent_game(title, 'steam', time, image: image, achievement: achievement)
        items << {
          platform:         'Steam',
          title:            title,
          achievement:      achievement ? achievement.name : false,
          achievement_time: achievement ? achievement.time : false,
          published:        time,
          url:              url,
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
        image = store_local_copy(item.imageUri.medium, 'switch', title)
        time = (index == 0) ? Time.at(daily_summary.items.first.lastPlayedAt) : item.firstPlayDate.to_date.beginning_of_day
        url = item.shopUri
        update_recent_game(title, 'switch', time, image: image, url: url)
        items << {
          platform:         'Switch',
          title:            title,
          published:        time,
          url:              url,
          image_url:        image ? image : find_game_image(title),
          thumb_url:        image ? image : find_game_image(title, true)
        }
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Nintendo games via API", exception).deliver_now
    end
    return items
  end

end
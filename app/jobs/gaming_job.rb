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
    rescue
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

end
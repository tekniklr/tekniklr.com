class GamingJob < ApplicationJob
  
  def perform
    manual_items = get_recent_games
    psn_items = get_psn_rss
    xbox_items = get_xbox
    steam_items = get_steam
    all_items = (manual_items + psn_items + xbox_items + steam_items).sort_by{|i| i.published ? i.published : Time.now-1000.years}.reverse
    parsed_items = []
    cheevos_kludged = []
    all_items.each do |item|
      if item.respond_to?('has_key?') && item.has_key?(:parsed) # manually created RecentGame
        title       = item.title
        platform    = item.platform
        published   = item.published
        url         = item.url
        thumb_url   = item.image.url(:thumb)
        image_url   = item.image.url(:default)
      elsif item.respond_to?('has_key?') && item.has_key?(:steam) # from Steam API
        title       = item.title
        platform    = item.platform
        published   = item.published
        achievement = item.achievement
        url         = item.url
        image_url   = item.image ? item.image : find_game_image(title)
        thumb_url   = item.image ? item.image : find_game_image(title, true)
      elsif item.respond_to?('has_key?') && item.has_key?(:xbox) # from OpenXBL API
        title       = item.title
        platform    = item.platform
        published   = item.published
        achievement = item.achievement
        image_url   = item.image ? item.image : find_game_image(title)
        thumb_url   = item.image ? item.image : find_game_image(title, true)
      else # parsed from True(Trophies|Achievements) RSS feeds
        Rails.logger.debug "Parsing #{item.title}..."
        item.title.match?(/tekniklr (started|completed)/) and next
        item.title.match(/tekniklr won the (.*) (trophy|achievement) in (.*)\z/)
        if ($1.blank? || $2.blank? || $3.blank?)
          puts "Couldn't parse an achievement, type, or game title from \"#{item.title}\"! Skipping."
          next
        end
        achievement = $1
        type = $2
        title = $3
        case type
        when 'trophy'
          platform = 'Playstation'
        when 'achievement'
          platform = 'Xbox'
        end
        title.gsub!(/ Trophies/, '')
        published = item.published
        url = item.url
        unless cheevos_kludged.include?(title)
          manual_published = manual_items.select{|g| g.title == title}.first
          if (manual_published && manual_published.published > published)
            published = manual_published.published+5.seconds
            cheevos_kludged << title
          end
        end
        image_url = find_game_image(title)
        thumb_url = find_game_image(title, true)
      end
      parsed_items << {
        title:               title,
        platform:            platform,
        achievement:         achievement,
        url:                 url,
        published:           published,
        thumb_url:           thumb_url,
        image_url:           image_url
      }
    end
    Rails.cache.write('gaming', parsed_items.sort_by{|i| i.published }.reverse.uniq{ |i| [i.title.downcase.gsub(/\s+/, ' ').gsub(/[^\w\s]/, '')] }[0..9])
  end
  
  private

  def find_game_image(title, thumb = false)
    Rails.logger.debug "Looking for upladed image for #{title}..."
    matching_game = RecentGame.by_name_with_image(title).first
    if matching_game && matching_game.image?
      thumb ? matching_game.image.url(:thumb) : matching_game.image.url(:default)
    else
      ''
    end
  end

  def get_recent_games
    Rails.logger.debug "Parsing manually entered games..."
    items = []
    RecentGame.first(12).each do |game|
      sort_time = Time.zone.local(game.started_playing.year, game.started_playing.month, game.started_playing.day, game.updated_at.hour, game.updated_at.min, game.updated_at.sec)
      items << {
        parsed:      true,
        platform:    game.platform,
        title:       game.name,
        url:         game.url,
        published:   sort_time,
        image:       game.image
      }
    end
    return items
  end

  # using truetrophies which seems to be one of the only reliable ways to turn 
  # PSN trophies into an RSS feed...
  def get_psn_rss
    Rails.logger.debug "Fetching PSN trophies from truetrophies..."
    get_xml('https://www.truetrophies.com/friendfeedrss.aspx?gamerid=26130', 'gaming_expiry')
  end

  # using the OpenXBL API at https://xbl.io/
  def get_xbox
    Rails.logger.debug "Fetching Xbox activity via OpenXBL API.."
    items = []
    begin
      games = make_request('https://xbl.io/api/v2/player/titleHistory', type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
      games.titles.select{|g| g.type == 'Game' }.first(9).each do |game|
        achievements = make_request("https://xbl.io/api/v2/achievements/player/#{Rails.application.credentials.xbox['id']}/#{game.titleId}", type: 'GET', headers: { 'x-authorization': Rails.application.credentials.xbox['api_key'] })
        newest_achievement = achievements.achievements.select{|a| a.progressState == 'Achieved'}.sort_by{|a| a.progression.timeUnlocked}.last
        items << {
            xbox:       true,
            platform:    'Xbox',
            title:       game.name,
            achievement: newest_achievement ? newest_achievement.name : false,
            published:   Time.new(game.titleHistory.lastTimePlayed).localtime,
            image:       store_local_copy(game.displayImage, "xbox_#{game.titleId}")
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
      steam_games = make_request('https://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, format: 'json' }).response
      (steam_games.total_count > 0) or return items
      steam_games.games.each do |game|
        game_achievements = make_request('https://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/', type: 'GET', params: { key: steam_api_key, steamid: steam_id, appid: game.appid, format: 'json' })
        newest_achievement = game_achievements.playerstats.has_key?('achievements') ? game_achievements.playerstats.achievements.select{|a| a.achieved == 1}.sort_by{|a| a.unlocktime}.last : false
        if newest_achievement
          items << {
            steam:       true,
            platform:    'Steam',
            title:       game.name,
            achievement: newest_achievement.has_key?('name') ? newest_achievement.name : newest_achievement.apiname,
            published:   Time.at(newest_achievement.unlocktime),
            url:         "https://store.steampowered.com/app/#{game.appid}/",
            image:       store_local_copy("https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/#{game.appid}/header.jpg", "steam_#{game.appid}")
          }
        end
      end
    rescue => exception
      ErrorMailer.background_error("fetching/parsing Steam achievements via API", exception).deliver_now
    end
    return items
  end

end
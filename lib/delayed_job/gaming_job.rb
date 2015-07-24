class DelayedJob::GamingJob
  include DelayedJob::AmazonJob
  
  def perform
    manual_items = get_recent_games
    psn_items = get_psn
    xbox_items = get_xbox
    steam_items = get_steam
    all_items = (manual_items + psn_items + xbox_items + steam_items).sort_by{|i| i.published ? i.published : Time.now-1000.years}.reverse
    parsed_items = []
    all_items.first(10).each do |item|
      if item.respond_to?('has_key?') && item.has_key?(:parsed)
        title = item.title
        platform = item.platform
        additional_keywords = platform
      else
        Rails.logger.debug "Parsing #{item.title}..."
        item.title.gsub(/tekniklr won the (.*) (trophy|achievement) in (.*)\z/, '')
        achievement = $1
        additional_keywords = case $2
          when 'trophy'
            'PS4'
          when 'achievement'
            'Xbox 360'
          else
            ''
          end
        title = $3.gsub(/ Trophies/, '')
      end
      amazon = get_amazon(title, 'VideoGames', additional_keywords)
      if amazon
        parsed_items << {
          :title        => title,
          :achievement  => achievement,
          :platform     => platform,
          :url          => item.url,
          :published    => item.published,
          :image_url    => amazon[:image_url],
          :amazon_url   => amazon[:amazon_url],
          :amazon_title => amazon[:amazon_title],
          :similarity   => amazon[:similarity]
        }
      elsif item.image
        parsed_items << {
          :title        => item.title,
          :platform     => platform,
          :url          => item.url,
          :published    => item.published,
          :image_url    => item.image.url(:default)
        }
      else
        parsed_items << {
          :title        => title,
          :achievement  => achievement,
          :url          => item.url,
          :published    => item.published
        }
      end
    end
    Rails.cache.write('gaming', parsed_items)
  end
  
  private


  def get_recent_games
    Rails.logger.debug "Parsing manually entered games..."
    items = []
    RecentGame.first(12).each do |game|
      items << {
        parsed:    true,
        platform:  game.platform,
        title:     game.name,
        url:       game.url,
        published: game.started_playing,
        image:     game.image
      }
    end
    return items
  end

  # using truetrophies which seems to be one of the only reliable ways to turn 
  # PSN trophies into an RSS feed...
  def get_psn
    Rails.logger.debug "Fetching PSN trophies from truetrophies..."
    begin
      feed  = Feedjira::Feed.fetch_and_parse('http://www.truetrophies.com/friendfeedrss.aspx?gamerid=26130')
      items = feed.entries
    rescue
      items = []
    end
    return items
  end

  # using trueachievements which works in the exact same way as truetrophies
  # even though I don't really play xbox anymore...
  def get_xbox
    Rails.logger.debug "Fetching xbox achievements from trueachievements..."
    begin
      feed  = Feedjira::Feed.fetch_and_parse('http://www.trueachievements.com/friendfeedrss.aspx?gamerid=294291')
      items = feed.entries
    rescue
      items = []
    end
    return items
  end

  # placeholder for one day when I know how to get steam achievements
  def get_steam
    Rails.logger.debug "Fetching steam achievements from ???..."
    items = []
    return items
  end

end
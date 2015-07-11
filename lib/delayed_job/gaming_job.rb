class DelayedJob::GamingJob
  include DelayedJob::AmazonJob
  
  def perform
    psn_items = get_psn
    xbox_items = get_xbox
    steam_items = get_steam
    all_items = (psn_items + xbox_items + steam_items).sort_by{|i| i.published ? i.published : Time.now-1000.years}.reverse
    parsed_items = []
    all_items.each do |item|
      Rails.logger.debug "Parsing #{item.title}..."
      item.title.gsub(/tekniklr won the (.*) (trophy|achievement) in (.*)\z/, '')
      achievement = $1
      additional_keywords = ($2 == 'trophy') ? 'ps4' : ''
      title = $3.gsub(/ Trophies/, '')
      amazon = get_amazon(title, 'VideoGames', additional_keywords)
      if amazon
        parsed_items << {
          :title        => title,
          :achievement  => achievement,
          :url          => item.url,
          :published    => item.published,
          :image_url    => amazon[:image_url],
          :amazon_url   => amazon[:amazon_url],
          :amazon_title => amazon[:amazon_title],
          :similarity   => amazon[:similarity]
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
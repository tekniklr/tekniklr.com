class DelayedJob::GamingJob
  require 'delayed_job/amazon_job'
  include DelayedJob::AmazonJob
  
  def perform
    Rails.logger.debug "Fetching Raptr checkins from RSS..."
    parsed_items = []
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://raptr.com/tekniklr/rss')
      items = feed.entries.uniq_by{|i| i.title}
    rescue
      items = []
    end
    previous_title = ''
    items.each do |item|
      !(item.url =~ /game-activity $/) and next # only care about game activity
      Rails.logger.debug "Parsing #{item.title}..."
      item.title.gsub(/(playing|session of|hours of|played|game of){1} (.+) \((PS3|360|PSN|XBLA)\)/, '')
      title = $2
      (title.blank? || title == previous_title) and next # be more interesting
      previous_title = title
      amazon = get_amazon(title, 'VideoGames')
      if amazon
        parsed_items << {
          :title      => title,
          :url        => item.url,
          :published  => item.published,
          :image_url  => amazon[:image_url],
          :amazon_url => amazon[:amazon_url]
        }
      else
        parsed_items << {
          :title      => title,
          :url        => item.url,
          :published  => item.published
        }
      end
    end
    Rails.cache.write('gaming', parsed_items)
  end
  
end
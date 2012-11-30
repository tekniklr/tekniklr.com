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
    previous_titles = []
    items.each do |item|
      !(item.url =~ /game-activity $/) and next # only care about game activity
      Rails.logger.debug "Parsing #{item.title}..."
      item.title.gsub(/(playing|session of|played [0-9]+ hour(s)? of|played a game of|played){1} (.+) \((PS3|360|PSN|XBLA)\)/, '')
      title = $3
      (title.blank? || ((previous_titles.count < 7) && previous_titles.include?(title))) and next # be more interesting, but try to show at least 7 things, still
      previous_titles << title
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
          :url        => item.url.gsub(/\A \/tekniklr/, 'http://raptr.com/tekniklr'),
          :published  => item.published
        }
      end
    end
    Rails.cache.write('gaming', parsed_items)
  end
  
end
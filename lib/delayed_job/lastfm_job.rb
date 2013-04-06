class DelayedJob::LastfmJob
  include DelayedJob::AmazonJob
  
  def perform
    Rails.logger.debug "Fetching last.fm scrobbles from RSS..."
    parsed_items = []
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://ws.audioscrobbler.com/1.0/user/tekniklr/recenttracks.rss')
      items = feed.entries.uniq_by{|i| i.title}[0..10]
    rescue
      items = []
    end
    items.each do |item|
      artist = item.title.gsub(/ – .+/, '') 
      amazon = get_amazon(artist, 'Music')
      if amazon
        parsed_items << {
          :title      => item.title,
          :published  => item.published,
          :image_url  => amazon[:image_url],
          :amazon_url => amazon[:amazon_url]
        }
      else
        parsed_items << {
          :title      => item.title,
          :published  => item.published,
          :lastfm_url => item.url
        }
      end
    end
    Rails.cache.write('lastfm', parsed_items)
  end
  
end
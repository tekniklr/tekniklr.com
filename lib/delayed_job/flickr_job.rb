class DelayedJob::FlickrJob
  
  def perform
    Rails.logger.debug "Fetching flickr photos from RSS..."
    begin
      feed   = Feedzirra::Feed.fetch_and_parse('http://api.flickr.com/services/feeds/photos_public.gne?id=7686648@N06&lang=en-us&format=rss_200')
      photos = feed.entries[0..5]
    rescue
      photos = []
    end
    found_photos = []
    photos.each do |photo|
      photo.summary =~ /img src=\"([0-9a-z\/:._]+)\"/
      if $1
        found_photos << {
          :title     => photo.title,
          :summary   => photo.summary,
          :src       => $1,
          :url       => photo.url,
          :published => photo.published
        }
      end
    end
    Rails.cache.write('flickr_photos', found_photos)
  end
  
end
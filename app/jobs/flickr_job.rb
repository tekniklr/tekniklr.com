class FlickrJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching flickr photos from RSS..."
    begin
      url    = 'https://api.flickr.com/services/feeds/photos_public.gne?id=7686648@N06&lang=en-us&format=rss_200'
      xml    = HTTParty.get(url).body
      feed   = Feedjira.parse(xml)
      photos = feed.entries[0..20]
    rescue => exception
      ErrorMailer.background_error('caching flickr photos', exception).deliver_now
      photos = []
    end
    found_photos = []
    photos.each do |photo|
      photo.summary =~ /img src=\"([0-9a-z\/:._]+)\"/
      photo.title = (photo.title == 'upload') ? nil : photo.title
      if $1
        found_photos << {
          title:     photo.title,
          summary:   photo.summary,
          src:       $1,
          url:       photo.url,
          published: photo.published
        }
      end
    end
    Rails.cache.write('flickr_photos', found_photos)
  end
  
end
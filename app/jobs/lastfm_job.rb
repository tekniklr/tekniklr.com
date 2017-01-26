class LastfmJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching last.fm scrobbles from RSS..."
    parsed_items = []
    begin
      require 'lastfm'
      lastfm = Lastfm.new(LASTFM_API_KEY, LASTFM_API_SECRET)
      recent_tracks = lastfm.user.get_recent_tracks(user: 'tekniklr')
      items = recent_tracks.uniq{|i| i.name}[0..10]
    rescue
      items = []
    end
    items.each do |item|
      artist = item.artist.key?('content') ? item.artist.content : ''
      album = item.album.key?('content') ? item.album.content : ''
      played_on = item.key?('date') ? DateTime.strptime(item.date.uts, '%s') : DateTime.now
      large_image = item.image.select{|i| i['size'] == 'large'}
      image_url = large_image.blank? ? '' : large_image.first['content']
      amazon = get_amazon("#{artist} #{album}", 'Music')
      if amazon
        parsed_items << {
          title:        item.name,
          artist:       artist,
          published:    played_on,
          image_url:    amazon[:image_url],
          amazon_url:   amazon[:amazon_url],
          amazon_title: amazon[:amazon_title],
          similarity:   amazon[:similarity]
        }
      else
        parsed_items << {
          title:      item.name,
          artist:     artist,
          published:  played_on,
          lastfm_url: item.url,
          image_url:  image_url,
        }
      end
    end
    Rails.cache.write('lastfm', parsed_items)
  end
  
end
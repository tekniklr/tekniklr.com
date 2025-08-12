class LastfmJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching last.fm scrobbles via API..."
    parsed_items = []
    keep_images = []
    begin
      require 'lastfm'
      lastfm = Lastfm.new(Rails.application.credentials.lastfm[:api_key], Rails.application.credentials.lastfm[:api_secret])
      recent_tracks = lastfm.user.get_recent_tracks(user: 'tekniklr')
      items = recent_tracks ? recent_tracks.uniq{|i| i.name || 'unnamed'}[0..15] : []
    rescue => exception
      ErrorMailer.background_error('caching Last.fm activity', exception).deliver_now
      items = []
    end
    items.each do |item|
      title = item.has_key?('name') ? item.name : 'unnamed'
      artist = item.artist.key?('content') ? item.artist.content : ''
      image_name = normalize_title("#{artist} - #{title}")
      keep_images << image_name
      album = item.album.key?('content') ? item.album.content : ''
      played_on = item.key?('date') ? DateTime.strptime(item.date.uts, '%s') : DateTime.now
      large_image = item.image.select{|i| i['size'] == 'large'}
      image_url = large_image.blank? ? '' : large_image.first['content']
      parsed_items << {
        title:      title,
        artist:     artist,
        published:  played_on,
        lastfm_url: item.url,
        image_url:  store_local_copy(image_url, 'lastfm', image_name),
      }
    end
    unless parsed_items.blank?
      Rails.cache.write('lastfm', parsed_items)
      clear_local_copies('lastfm', keep_images)
    end
  end
  
end
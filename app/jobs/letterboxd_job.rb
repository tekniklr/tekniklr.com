class LetterboxdJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching LetterBoxd checkins from RSS..."
    parsed_items = []
    items = get_xml('https://letterboxd.com/tekniklr/rss/', 'letterboxd_expiry')
    items = items.uniq{|i| i.title}
    previous_titles = []
    items.each do |item|
      Rails.logger.debug "Parsing #{item.title}..."
      item.title =~ /(.+), ([0-9]{4}) - (★+½?)\z/
      title = $1
      year = $2
      rating = $3
      (title.blank? || previous_titles.include?(title)) and next
      previous_titles << title
      orig_image_url = (Nokogiri::HTML(item.summary).css("img")[0]['src']).gsub(/\?.*/, '')
      thumb_url = orig_image_url.gsub(/_S[A-Z][0-9]+_\.jpg/, '_SY100_.jpg')
      image_url = orig_image_url.gsub(/_S[A-Z][0-9]+_\.jpg/, '_SY300_.jpg')
      parsed_items << {
        title:     title,
        year:      year,
        rating:    rating,
        url:       item.url,
        published: item.published,
        thumb_url: store_local_copy(thumb_url, 'letterboxd_thumb', normalize_title(title)),
        image_url: store_local_copy(image_url, 'letterboxd_big', normalize_title(title))
      }
    end
    Rails.cache.write('letterboxd', parsed_items)
    keep_titles = parsed_items.collect{|item| normalize_title(item.title)}
    clear_local_copies('letterboxd_thumb', keep_titles)
    clear_local_copies('letterboxd_big', keep_titles)
  end
  
end
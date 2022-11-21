class GoodreadsJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching Goodreads checkins from RSS..."
    parsed_items = []
    items = get_xml('https://www.goodreads.com/user/updates_rss/10905654?key=80323864cb4de1c67549229f456b630a729c213a', 'goodreads_expiry')
    items = items.uniq{|i| i.title}
    previous_titles = []
    items.each do |item|
      Rails.logger.debug "Parsing #{item.title}..."
      item.title.gsub(/(started reading|finished reading|currently reading|added){1} '(.+)'/, '')
      title = $2
      (title.blank? || previous_titles.include?(title)) and next
      previous_titles << title
      orig_image_url = Nokogiri::HTML(item.summary).css("img")[0]['src']
      thumb_url = orig_image_url.gsub(/_S[A-Z][0-9]+_\.jpg/, '_SY100_.jpg')
      image_url = orig_image_url.gsub(/_S[A-Z][0-9]+_\.jpg/, '_SY300_.jpg')
      parsed_items << {
        title:     title,
        url:       item.url,
        published: item.published,
        thumb_url: thumb_url,
        image_url: image_url
      }
    end
    Rails.cache.write('goodreads', parsed_items)
  end
  
end
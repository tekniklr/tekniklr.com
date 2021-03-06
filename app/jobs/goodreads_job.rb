class GoodreadsJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching Goodreads checkins from RSS..."
    parsed_items = []
    begin
      url   = 'https://www.goodreads.com/user/updates_rss/10905654?key=80323864cb4de1c67549229f456b630a729c213a'
      xml   = HTTParty.get(url).body
      feed  = Feedjira.parse(xml)
      items = feed.entries.uniq{|i| i.title}
    rescue => exception
      ErrorMailer.background_error('caching goodreads activity', exception).deliver_now
      items = []
    end
    previous_titles = []
    items.each do |item|
      Rails.logger.debug "Parsing #{item.title}..."
      item.title.gsub(/(started reading|finished reading|currently reading|added){1} '(.+)'/, '')
      title = $2
      (title.blank? || previous_titles.include?(title)) and next
      previous_titles << title
      image_url = Nokogiri::HTML(item.summary).css("img")[0]['src']
      parsed_items << {
        title:     title,
        url:       item.url,
        published: item.published,
        image_url: image_url
      }
    end
    Rails.cache.write('goodreads', parsed_items)
  end
  
end
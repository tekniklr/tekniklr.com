class DelayedJob::GoodreadsJob
  include DelayedJob::AmazonJob
  
  def perform
    Rails.logger.debug "Fetching Goodreads checkins from RSS..."
    parsed_items = []
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://www.goodreads.com/user/updates_rss/10905654?key=80323864cb4de1c67549229f456b630a729c213a')
      items = feed.entries.uniq_by{|i| i.title}
    rescue
      items = []
    end
    previous_titles = []
    items.each do |item|
      Rails.logger.debug "Parsing #{item.title}..."
      item.title.gsub(/(started reading|finished reading|currently reading){1} '(.+)'/, '')
      title = $2
      (title.blank? || previous_titles.include?(title)) and next
      previous_titles << title
      amazon = get_amazon(title, 'Books')
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
    Rails.cache.write('goodreads', parsed_items)
  end
  
end
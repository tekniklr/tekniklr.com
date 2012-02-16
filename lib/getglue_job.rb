class GetglueJob
  require 'amazon_job'
  include AmazonJob
  
  def perform
    Rails.logger.debug "Fetching getglue checkins from RSS..."
    parsed_items = []
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://feeds.getglue.com/checkins/0%22jFMxg4Rtl')
      items = feed.entries.uniq_by{|i| i.title}[0..7]
      items.each do |item|
        Rails.logger.debug "Parsing #{item.title}..."
        item.title.gsub!(/Teri Solow is ([A-Za-z]+) (to )?/, '')
        case $1
        when "watching"
          type = 'DVD'
        when "reading"
          type = 'Books'
        when "playing"
          type = 'VideoGames'
        when "listening"
          type = 'Music'
        end
        if type
          amazon = get_amazon(item.title, type)
          if amazon
            Rails.logger.debug "Amazon product found!"
            parsed_items << {
              :title      => item.title,
              :url        => item.url,
              :published  => item.published,
              :image_url  => amazon[:image_url],
              :amazon_url => amazon[:amazon_url]
            }
          else
            Rails.logger.debug "Amazon product not found"
            parsed_items << {
              :title      => item.title,
              :url        => item.url,
              :published  => item.published
            }
          end
        end
      end
    rescue
      ''
    end
    Rails.cache.write('getglue', parsed_items)
  end
  
end
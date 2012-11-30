class DelayedJob::GetglueJob
  require 'delayed_job/amazon_job'
  include DelayedJob::AmazonJob
  
  def perform
    Rails.logger.debug "Fetching getglue checkins from RSS..."
    parsed_items = []
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://feeds.getglue.com/checkins/0%22jFMxg4Rtl')
      items = feed.entries.uniq_by{|i| i.title}
    rescue
      items = []
    end
    items.each do |item|
      Rails.logger.debug "Parsing #{item.title}..."
      item.title.gsub!(/Teri Solow is ([A-Za-z]+) (to )?/, '')
      case $1
      when "watching"
        type = 'DVD'
      when "reading"
        type = 'Books'
      when "listening"
        type = 'Music'
      end
      if type
        amazon = get_amazon(item.title, type)
        if amazon
          parsed_items << {
            :title      => item.title,
            :url        => item.url,
            :published  => item.published,
            :image_url  => amazon[:image_url],
            :amazon_url => amazon[:amazon_url]
          }
        else
          parsed_items << {
            :title      => item.title,
            :url        => item.url,
            :published  => item.published
          }
        end
      end
    end
    Rails.cache.write('getglue', parsed_items)
  end
  
end
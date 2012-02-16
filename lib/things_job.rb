class ThingsJob < Struct.new(:favorites)
  require 'amazon_job'
  include AmazonJob
  
  def perform
    things = {}
    favorites.each do |favorite|
      case favorite.favorite_type
      when "Movies", "TV", "Anime"
        amazon_type = 'DVD'
      when "Literature"
        amazon_type = 'Books'
      when "Video Games"
        amazon_type = 'VideoGames'
      when "Music"
        amazon_type = 'Music'
      end
      if amazon_type
        favorite.favorite_things.each do |thing|
          amazon_data = get_amazon(thing.thing, amazon_type)
          if amazon_data
            Rails.logger.debug "Amazon product found!"
            things[thing.thing] = {
              :image_url  => amazon_data[:image_url],
              :amazon_url => amazon_data[:amazon_url]
            }
          end
        end
      end
    end
    Rails.cache.write('things_amazon', things)
  end
  
end
class DelayedJob::ThingsJob < Struct.new(:favorites)
  include DelayedJob::AmazonJob
  
  def perform
    things = {}
    Favorite.all.each do |favorite|
      # for valid amazon item categories, see http://docs.aws.amazon.com/AWSECommerceService/latest/DG/USSearchIndexParamForItemsearch.html
      case favorite.favorite_type
      when "Movies", "TV", "Anime"
        amazon_type = 'DVD'
      when "Books"
        amazon_type = 'Books'
      when "Video Games"
        amazon_type = 'VideoGames'
      when "Board Games"
        amazon_type = 'Toys'
      when "Music"
        amazon_type = 'Music'
      else
        amazon_type = 'All'
      end
      if amazon_type
        favorite.favorite_things.each do |thing|
          amazon_data = get_amazon(thing.thing, amazon_type)
          if amazon_data
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
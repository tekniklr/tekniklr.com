class DelayedJob::ThingsJob < Struct.new(:favorites)
  include DelayedJob::AmazonJob
  
  def perform
    things = {}
    Favorite.all.each do |favorite|
      amazon_type = 'All'
      additional_keywords = ''
      # for valid amazon item categories, see https://docs.aws.amazon.com/AWSECommerceService/latest/DG/LocaleUS.html
      case favorite.favorite_type
      when "Movies", "TV", "Anime"
        amazon_type = 'DVD'
      when "Books"
        amazon_type = 'Books'
      when "Video Games"
        amazon_type = 'VideoGames'
        additional_keywords = 'ps4'
      when "Board Games"
        amazon_type = 'Toys'
      when "Music"
        amazon_type = 'Music'
      end
      favorite.favorite_things.each do |thing|
        amazon = get_amazon(thing.thing, amazon_type, additional_keywords)
        if amazon
          things[thing.thing] = {
            :image_url    => amazon[:image_url],
            :amazon_url   => amazon[:amazon_url],
            :amazon_title => amazon[:amazon_title],
            :similarity   => amazon[:similarity]
          }
        end
      end
    end
    Rails.cache.write('things_amazon', things)
  end
  
end
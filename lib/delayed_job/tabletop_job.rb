class DelayedJob::TabletopJob < Struct.new(:tabletop_games)
  include DelayedJob::AmazonJob
  
  def perform
    things = {}
    TabletopGame.all.each do |game|
      amazon_data = get_amazon(game.name, 'Toys')
      if amazon_data
        things[game.name] = {
          :image_url  => amazon_data[:image_url],
          :amazon_url => amazon_data[:amazon_url]
        }
      end
    end
    Rails.cache.write('tabletop_amazon', things)
  end
  
end
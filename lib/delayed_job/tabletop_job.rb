class DelayedJob::TabletopJob < Struct.new(:tabletop_games)
  include DelayedJob::AmazonJob
  
  def perform
    things = {}
    TabletopGame.all.each do |game|
      amazon = get_amazon(game.name, 'Toys')
      if amazon
        things[game.name] = {
          :image_url    => amazon[:image_url],
          :amazon_url   => amazon[:amazon_url],
          :amazon_title => amazon[:amazon_title],
          :similarity   => amazon[:similarity]
        }
      end
    end
    Rails.cache.write('tabletop_amazon', things)
  end
  
end
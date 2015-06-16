namespace :tekniklr do
  
  desc "Delete all data and expiries cached for delayed job tasks, causing them to be re-run after the next page load. Does NOT delete cached Amazon items."
  task :reset_jobs => :environment do
    cached_items = [
      'tumblr_expiry',
      'tumblr_posts',
      'delicious_expiry',
      'delicious',
      'flickr_expiry',
      'flickr_photos',
      'goodreads_expiry',
      'goodreads',
      'lastfm_expiry',
      'lastfm',
      'gaming_expiry',
      'gaming',
      'things_expiry',
      'things_amazon',
      'tabletop_fetched',
      'tabletop_amazon'
    ]
    cached_items.each do |item|
      puts "Trying to remove #{item} from cache..."
      if Rails.cache.delete(item)
        puts "\tBALEETED"
      end
    end
  end

  desc "Delete cached Amazon data."
  task :reset_amazon => :environment do
    puts "Trying to remove amazon_items from cache..."
    if Rails.cache.delete('amazon_items')
      puts "\tBALEETED"
    end
  end

end
namespace :tekniklr do
  
  desc "Delete all data and expiries cached for delayed job tasks, causing them to be re-run after the next page load."
  task :reset_jobs => :environment do
    CACHED_ITEMS.each do |item|
      puts "Trying to remove #{item} from cache..."
      if Rails.cache.delete(item)
        puts "\tBALEETED"
      end
    end
  end

end
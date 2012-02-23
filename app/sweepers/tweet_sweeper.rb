class TweetSweeper < ActionController::Caching::Sweeper
  observe Tweet

  def after_destroy(tweet)
     expire_cache_for(tweet)
  end
  
  private
  
  def expire_cache_for(tweet)
    Rails.cache.delete('tweets')
  end
end
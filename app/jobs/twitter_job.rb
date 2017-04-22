class TwitterJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching twitter via API..."
    begin
      require 'twitter'
      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key        = CONSUMER_KEY
        config.consumer_secret     = CONSUMER_SECRET
        config.access_token        = ACCESS_TOKEN
        config.access_token_secret = ACCESS_TOKEN_SECRET
      end
      tweets = twitter.user_timeline('tekniklr', {count: 42, exclude_replies: true, include_rts: true, trim_user: false} )
    rescue
      twitter_user = {}
      tweets = []
    end
    Rails.cache.write('tweets', tweets)
  end
  
end
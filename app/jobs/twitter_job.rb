class TwitterJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching twitter via API..."
    begin
      require 'twitter'
      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.credentials.twitter[:consumer_key]
        config.consumer_secret     = Rails.application.credentials.twitter[:consumer_secret]
        config.access_token        = Rails.application.credentials.twitter[:access_token]
        config.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
      end
      tweets = twitter.user_timeline('tekniklr', {count: 69, exclude_replies: false, include_rts: true, trim_user: false, tweet_mode: 'extended'} )
      if tweets.first.created_at.to_datetime < Time.now-1.week
        # if I haven't tweeted in a while, don't show old shit
        tweets = []
      end
    rescue => exception
      ErrorMailer.background_error('caching tweets', exception).deliver_now
      tweets = []
    end
    Rails.cache.write('tweets', tweets)
  end
  
end
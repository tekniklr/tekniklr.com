class TwitterJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching twitter via API..."
    begin
      require 'twitter'
      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.credentials.twitter[:api_key]
        config.consumer_secret     = Rails.application.credentials.twitter[:api_secret]
        config.access_token        = Rails.application.credentials.twitter[:access_token]
        config.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
      end
      tweets = twitter.user_timeline('tekniklr', {count: 69, exclude_replies: false, include_rts: true, trim_user: false, tweet_mode: 'extended'} )
      if tweets.empty? || (tweets.first.created_at.to_datetime < Time.now-1.week)
        # if I haven't tweeted in a while, don't show old shit
        tweets = []
      end
    rescue Twitter::Error::Unauthorized
      # think this happens when I exceed the new 25 request per 24 hour limit
      # increase the refresh limit, accordingly, without replacing any cached
      # tweets we already have
      Rails.cache.write('tweet_expiry', (Time.now + 24.hours))
      return
    rescue => exception
      ErrorMailer.background_error('caching tweets', exception).deliver_now
      tweets = []
    end
    Rails.cache.write('tweets', tweets)
  end
  
end
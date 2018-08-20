class TwitterJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching twitter via API..."
    begin
      require 'twitter'
      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key        = TWITTER_CONSUMER_KEY
        config.consumer_secret     = TWITTER_CONSUMER_SECRET
        config.access_token        = TWITTER_ACCESS_TOKEN
        config.access_token_secret = TWITTER_ACCESS_TOKEN_SECRET
      end
      tweets = twitter.user_timeline('tekniklr', {count: 69, exclude_replies: false, include_rts: true, trim_user: false, tweet_mode: 'extended'} )
      if tweets.first.created_at.to_datetime < Time.now-1.week
        # if I haven't tweeted in a while, maybe I've quit twitter? it's
        # plausible, as twitter is only getting worse. don't show tweets, in
        # that case.
        twitter_user = {}
        tweets = []
      end
    rescue
      twitter_user = {}
      tweets = []
    end
    Rails.cache.write('tweets', tweets)
  end
  
end
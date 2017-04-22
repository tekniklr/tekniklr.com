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
      twitter_user = twitter.user('tekniklr')
      tweets = twitter.user_timeline('tekniklr', {count: 42, exclude_replies: true, include_rts: true, trim_user: true} )
      twitter_avatars = {}
      tweets.each do |tweet|
        if tweet.retweeted?
          retweeted_handle = tweet.user_mentions.first.screen_name
          retweeted_user = twitter.user(retweeted_handle)
          twitter_avatars[retweeted_handle] = retweeted_user
        end
      end
    rescue
      twitter_user = {}
      tweets = []
      twitter_avatars = {}
    end
    Rails.cache.write('twitter_user', twitter_user)
    Rails.cache.write('tweets', tweets)
    Rails.cache.write('twitter_avatars', twitter_avatars)
  end
  
end
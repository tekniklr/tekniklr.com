class TumblrJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching tumblr from RSS..."
    begin
      feed  = Feedjira::Feed.fetch_and_parse('http://tekniklr.tumblr.com/rss')
      posts = [feed.entries.first]
    rescue
      posts = []
    end
    Rails.cache.write('tumblr_posts', posts)
  end
  
end
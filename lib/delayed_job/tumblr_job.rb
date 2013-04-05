class DelayedJob::TumblrJob
  require 'delayed_job/tumblr_job'
  
  def perform
    Rails.logger.debug "Fetching tumblr from RSS..."
    begin
      feed  = Feedzirra::Feed.fetch_and_parse('http://tekniklr.tumblr.com/rss')
      posts = feed.entries.uniq_by{|p| p.title}
    rescue
      posts = []
    end
    Rails.cache.write('tumblr_posts', posts)
  end
  
end
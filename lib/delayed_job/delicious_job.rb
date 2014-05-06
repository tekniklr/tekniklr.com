class DelayedJob::DeliciousJob
  
  def perform
    Rails.logger.debug "Fetching delicious bookmarks from RSS..."
    begin
      feed      = Feedjira::Feed.fetch_and_parse('http://feeds.delicious.com/v2/rss/tekniklr?count=4')
      bookmarks = feed.entries[0..4]
    rescue
      bookmarks = []
    end
    Rails.cache.write('delicious', bookmarks)
  end
  
end
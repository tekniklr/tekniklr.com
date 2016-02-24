class DelayedJob::DeliciousJob
  
  def perform
    # wtf/explanation:
    # the delicious CDN is serving very out of date files to my web host's 
    # server, whereas I can easily get a current file. SO, I've set up a 
    # script on my home computer to wget the rss file and then scp it to my 
    # web host. so, here, we'll look for a local copy of the rss feed, use 
    # that if it is available, and fall back to trying to grab a file through 
    # the wonky CDN.
    local_rss_file = "#{Rails.root}/tmp/delicious.rss"
    if File.exists? local_rss_file
      Rails.logger.debug "Parsing local delicious bookmarks file..."
      opened_rss_file = File.open local_rss_file
      xml = opened_rss_file.read
      feed = Feedjira::Feed.parse xml
      opened_rss_file.close
    else
      Rails.logger.debug "Fetching delicious bookmarks from RSS..."
      begin
        feed = Feedjira::Feed.fetch_and_parse('http://feeds.delicious.com/v2/rss/tekniklr')
      rescue => exception
        Rails.logger.warn "Error fetching delicious feed! (#{exception.class})"
      end
    end

    begin
      bookmarks = feed.entries.reject{|e| e.author != 'tekniklr'}[0..3]
    rescue
      bookmarks = []
    end
    
    Rails.cache.write('delicious', bookmarks)
  end
  
end
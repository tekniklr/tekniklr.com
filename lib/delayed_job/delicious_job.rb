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
      Rails.logger.debug "Using local delicious bookmarks file..."
      opened_rss_file = File.open local_rss_file
      xml = opened_rss_file.read
      opened_rss_file.close
    else
      Rails.logger.debug "Fetching delicious bookmarks from RSS..."
      xml = Net::HTTP.get(URI.parse('http://feeds.delicious.com/v2/rss/tekniklr'))
    end

    # ADDITIONALLY, the delicious rss feed has been sending invalid RSS which
    # feedjira is unable to parse, so remove any of that
    Rails.logger.debug "Removing broken items from RSS..."
    xml = xml.gsub('&amp;', '[replaced_amp]').gsub('&', '&amp;').gsub('[replaced_amp]', '&amp;')

    begin
      Rails.logger.debug "Parsing RSS..."
      feed = Feedjira::Feed.parse xml
      bookmarks = feed.entries.reject{|e| e.author != 'tekniklr'}[0..3]
    rescue
      bookmarks = []
    end
    
    Rails.cache.write('delicious', bookmarks)
  end
  
end
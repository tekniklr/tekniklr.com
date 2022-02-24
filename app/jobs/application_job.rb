class ApplicationJob < ActiveJob::Base

  def get_xml(url, cache = false)
    items = []
    error = false
    begin
      xml   = HTTParty.get(url).body
      feed  = Feedjira.parse(xml)
      items = feed.entries
    rescue Feedjira::NoParserAvailable => exception
      error = true
      ErrorMailer.background_error("parsing XML file from #{url}", exception, "recieved XML:\n\n#{xml}").deliver_now
    rescue => exception
      error = true
      ErrorMailer.background_error("fetching/parsing XML file from #{url}", exception).deliver_now
    end
    if error && cache
      # if something is wrong with the external XML feed, don't keep trying it
      # on the normal schedule. wait a day.
      # this is necessary because sometimes the Dreamhost server IPs get banned
      # on CloudFlare and I'll get emails about it every few hours until it
      # gets fixed. I'd like fewer error emails.
      Rails.cache.write(cache, (Time.now + 1.day))
    end
    return items
  end

end
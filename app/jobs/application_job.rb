class ApplicationJob < ActiveJob::Base

  def get_xml(url)
    items = []
    begin
      xml   = HTTParty.get(url).body
      feed  = Feedjira.parse(xml)
      items = feed.entries
    rescue Feedjira::NoParserAvailable => exception
      ErrorMailer.background_error("parsing XML file from #{url}", exception, "recieved XML:\n\n#{xml}").deliver_now
    rescue => exception
      ErrorMailer.background_error("fetching/parsing XML file from #{url}", exception).deliver_now
    end
    return items
  end

end
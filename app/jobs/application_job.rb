class ApplicationJob < ActiveJob::Base

  protected

  def get_xml(url, cache = false)
    items = []
    error = false
    begin
      xml   = HTTParty.get(url).body
      feed  = Feedjira.parse(xml)
      items = feed.entries
    rescue Feedjira::NoParserAvailable => exception
      error = true
      ErrorMailer.background_error("parsing XML file from #{url}", exception, "received XML:\n\n#{xml}").deliver_now
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

  def http_status_good(url)
    HTTParty.get(url).response.code == '200'
  end

  # Makes a request to an API - originally from talking to Bluesky API, but
  # easily more general purpose
  def make_request(url, body: {}, params: {}, headers: {}, type: 'POST', auth_token: false, auth_type: 'Bearer', content_type: "application/json")
    Rails.logger.debug "Making #{type} request to #{url}..."
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 4
    http.read_timeout = 4
    http.write_timeout = 4

    params.present? and uri.query = URI.encode_www_form(params)

    request = (type == 'POST') ? Net::HTTP::Post.new(uri.request_uri) : Net::HTTP::Get.new(uri.request_uri)
    request["content-type"] = content_type

    if auth_token
      request["Authorization"] = "#{auth_type} #{auth_token}"
    end

    if headers.present?
      headers.each do |key, value|
        request[key] = value
      end
    end

    request.body = body.is_a?(Hash) ? body.to_json : body if body.present?

    response = http.request(request)
    case response
    when Net::HTTPSuccess then
      # all good
    when Net::HTTPRedirection then
      # for a redirect, don't process automatically here (while it would be
      # easy enough to call make_request() adain with this location, it's
      # possible there is additional metadata in the location params to work
      # with [this is true for the PlayStation API, apparently])
      return response['location']
    else
      raise "#{response.code} response - #{response.inspect}"
    end

    response.content_type == "application/json" ? JSON.parse(response.body) : response.body
  end

end
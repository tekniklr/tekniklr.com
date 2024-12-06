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
  def make_request(url, body: {}, params: {}, type: 'POST', auth_token: false, content_type: "application/json")
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 4
    http.read_timeout = 4
    http.write_timeout = 4

    params.present? and uri.query = URI.encode_www_form(params)

    request = (type == 'POST') ? Net::HTTP::Post.new(uri.request_uri) : Net::HTTP::Get.new(uri.request_uri)
    request["content-type"] = content_type

    # This allows the authorization token to:
    #   - Be sent using the currently stored token (true).
    #   - Not send when providing the username/password to generate the token (false).
    #   - Use a different token - like the refresh token (string).
    if auth_token
      request["Authorization"] = "Bearer #{auth_token}"
    end

    request.body = body.is_a?(Hash) ? body.to_json : body if body.present?

    response = http.request(request)
    raise "#{response.code} response - #{response.body}" unless response.code.to_s.start_with?("2")

    response.content_type == "application/json" ? JSON.parse(response.body) : response.body
  end

end
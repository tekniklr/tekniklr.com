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

  # useful when a job references a remote image which should be served locally
  def store_local_copy(url, filename)
    # this folder doesn't persist across deployments - this is fine as this
    # is really just a cache that would normallly go in a tmp directory, but
    # it is easiest to serve these assets directly as opposed to sending tmp
    # files via rails for them - they are probably just local caches of
    # remote public images
    unless File.exist?(File.join(Rails.public_path, 'remote_cache'))
      Dir.mkdir(File.join(Rails.public_path, 'remote_cache'))
    end

    file_path = File.join(Rails.public_path, 'remote_cache', filename)
    web_path = Rails.application.routes.url_helpers.root_path+"remote_cache/"+filename

    # if there is already a file with the specified filename then just return
    # that path
    File.exist?(file_path) and return web_path

    # if we can't actually get the remote copy then don't do anything
    http_status_good(url) or return false

    # if we got to this point, download the remote asset and store it
    File.open(file_path, "w") do |file|
      file.binmode
      HTTParty.get(url, stream_body: true) do |fragment|
        file.write(fragment)
      end
    end

    return web_path
  end

  # Makes a request to an API - originally from talking to Bluesky API, but
  # easily more general purpose
  MAX_TRIES = 5
  def make_request(url, body: {}, params: {}, headers: {}, type: 'POST', auth_token: false, auth_type: 'Bearer', content_type: "application/json", tries: 1)
    Rails.logger.debug "Attempt #{tries}/#{MAX_TRIES}: #{type} request to #{url}..."
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

    begin
      response = http.request(request)
    rescue Net::ReadTimeout => exception
      if tries <= MAX_TRIES
        response = make_request(url, body: body, params: params, headers: headers, type: type, auth_token: auth_token, auth_type: auth_type, content_type: content_type, tries: tries+1)
      else
        raise exception
      end
    end

    case response
    when Net::HTTPSuccess then
      # all good
    when Net::HTTPRedirection then
      # for a redirect, don't process automatically here (while it would be
      # easy enough to call make_request() again with this location, it's
      # possible there are additional metadata in the location params to do
      # something else with [this is true for the PlayStation API, apparently])
      return response['location']
    when Net::HTTPTooManyRequests then
      raise "#{response.code} response after #{tries} attempts - #{response.inspect}"
    else
      if response.is_a?(Net::HTTPBadRequest) && JSON.parse(response.body).has_key?('playerstats')
        # the steam API really overreacts when a game has no achievements and
        # you try to query those achievements
        return JSON.parse(response.body)
      elsif tries < MAX_TRIES
        # otherwise, retry in case this is a transient error
        response = make_request(url, body: body, params: params, headers: headers, type: type, auth_token: auth_token, auth_type: auth_type, content_type: content_type, tries: tries+1)
      else
        # other otherwise, give up
        raise "#{(response.is_a?(Hash) && response.has_key?('code')) ? response.code : 'Unanticipated'} response after #{MAX_TRIES} attempts - #{response.inspect}"
      end
    end

    response.content_type == "application/json" ? JSON.parse(response.body) : response.body
  end

end
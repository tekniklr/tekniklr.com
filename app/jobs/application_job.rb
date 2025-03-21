class ApplicationJob < ActiveJob::Base

  protected

  # sometimes querying a service has a temporary error - in this case we
  # shoudn't clobber good but stale data
  # useful for instances like with gaming services, which each get queried
  # separately and combined into a single cambined cache object used elsewhere
  # in the app
  def cache_if_present(cache_key, value)
    previous_value = Rails.cache.read(cache_key)
    if previous_value.blank? && value.blank?
       # trust that value was passed in as either [] or nil, and which should
       # be returned depends on context
      return value
    elsif value.blank?
      # don't clobber existing cache
      return previous_value
    else
      # cache new value, and return it
      Rails.cache.write(cache_key, value)
      return value
    end
  end

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
      # on the normal schedule. wait longer.
      # this is necessary because sometimes the Dreamhost server IPs get banned
      # on CloudFlare and I'll get emails about it every few hours until it
      # gets fixed. I'd like fewer error emails.
      Rails.cache.write(cache, (Time.now + 6.hours))
    end
    return items
  end

  # removes all non-alphanumeric characters and whitespace, to hopefully be
  # more able to compare matching titles from different sources
  def normalize_title(title)
    title.downcase.gsub(/[^A-Za-z0-9]/, '')
  end

  def http_status_good(url)
    HTTParty.get(url).response.code == '200'
  end

  # useful when a job references a remote image which should be served locally
  def store_local_copy(url, platform, filename)
    Rails.logger.debug "Storing locally cached file: #{filename} for #{platform} from #{url}..."
    unless File.exist?(File.join(Rails.public_path, 'remote_cache'))
      Dir.mkdir(File.join(Rails.public_path, 'remote_cache'))
    end

    filename = platform+'_'+normalize_title(filename)
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

  # will remove all locally cached remote files for a platform, unless they
  # match any filenams provided in keep_filenames
  def clear_local_copies(platform, keep_filenames = [])
    exclude_files = keep_filenames.collect do |filename|
      platform+'_'+normalize_title(filename)
    end
    remote_cache_dir = Rails.root.join(Rails.public_path, 'remote_cache')
    remote_cache_dir.children.each do |file|
      file.file? or next
      (file.basename.to_s =~ /\A#{platform}_/) or next
      exclude_files.include?(file.basename.to_s) and next
      Rails.logger.debug "Deleting cached file: #{file.basename}"
      File.delete(file)
    end
  end

  # Makes a request to an API - originally from talking to Bluesky API, but
  # easily more general purpose
  MAX_TRIES = 5
  def make_request(url, body: {}, params: {}, headers: {}, type: 'POST', auth_token: false, auth_type: 'Bearer', user_agent: 'Ruby', content_type: "application/json", tries: 1)
    Rails.logger.debug "Attempt #{tries}/#{MAX_TRIES}: #{type} request to #{url}..."

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 10
    http.read_timeout = 60
    http.write_timeout = 60

    params.present? and uri.query = URI.encode_www_form(params)

    headers["content-type"] = content_type
    if auth_token
      headers["Authorization"] = "#{auth_type} #{auth_token}"
    end
    headers['user-agent'] = user_agent

    request = (type == 'POST') ? Net::HTTP::Post.new(uri.request_uri, headers) : Net::HTTP::Get.new(uri.request_uri, headers)

    request.body = body.is_a?(Hash) ? body.to_json : body if body.present?

    begin
      response = http.request(request)
    rescue Net::ReadTimeout => exception
      if tries < MAX_TRIES
        response = make_request(url, body: body, params: params, headers: headers, type: type, auth_token: auth_token, auth_type: auth_type, user_agent: user_agent, content_type: content_type, tries: tries+1)
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
    when Net::HTTPTooManyRequests, Net::HTTPForbidden then
      raise net_http_error(response, tries: tries)
    else
      if response.is_a?(Net::HTTPBadRequest) && JSON.parse(response.body).has_key?('playerstats')
        # the steam API really overreacts when a game has no achievements and
        # you try to query those achievements
        return JSON.parse(response.body)
      elsif response.is_a?(Net::HTTPBadRequest)
        raise net_http_error(response, tries: tries)
      elsif tries < MAX_TRIES
        # otherwise, retry in case this is a transient error
        response = make_request(url, body: body, params: params, headers: headers, type: type, auth_token: auth_token, auth_type: auth_type, user_agent: user_agent, content_type: content_type, tries: tries+1)
      else
        # other otherwise, give up
        raise net_http_error(response, tries: tries)
      end
    end

    if response.respond_to?('content_type') && response.respond_to?('body')
      response.content_type == "application/json" ? JSON.parse(response.body) : response.body
    elsif tries < MAX_TRIES
      # retry in case this is a transient error
      make_request(url, body: body, params: params, headers: headers, type: type, auth_token: auth_token, auth_type: auth_type, user_agent: user_agent, content_type: content_type, tries: tries+1)
    else
      raise net_http_error(response, tries: tries, additional_message: "got a malformed response lacking a content_type or a body")
    end
  end

  private

  def net_http_error(response, tries: false, additional_message: false)
    message = "#{response.respond_to?('code') ? response.code : 'Unanticipated'} response"
    tries and message += " after #{tries} attempts"
    additional_message and message += "; #{additional_message}"
    message += " - \n"
    if response.respond_to?('content_type') && response.respond_to?('body')
      message += (response.content_type == "application/json") ? JSON.parse(response.body).inspect : response.body.inspect
    else
      message += response.inspect
    end
    message
  end

end
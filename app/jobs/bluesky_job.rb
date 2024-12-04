class BlueskyJob < ApplicationJob
  
  # inspired by and adapted from https://t27duck.com/posts/17-a-bluesky-at-proto-api-example-in-ruby

  def perform
    Rails.logger.debug "Fetching BlueSky via API..."
    @base_url = 'https://bsky.social/xrpc'
    @token_cache = 'bluesky_token_cache'
    begin

      # authenticate
      token_data = Rails.cache.read(@token_cache)
      process_tokens(token_data) if token_data.present?

      # fetch all skeets
      verify_tokens
      posts = make_request("#{@base_url}/app.bsky.feed.getAuthorFeed", type: 'GET', params: { actor: @user_did, limit: 100 })

      # iterate through all retrieved posts, adding onew beneath the delete 
      # limit to cache for later display, and deleting ones above the limit
      skeets = []
      newest_skeet = nil
      posts['feed'].each do |post|
        post_is_reskeet = (post.post.viewer.has_key?('repost'))
        posted_at = post_is_reskeet ? Time.new(post.reason.indexedAt) : Time.new(post.post.record.createdAt)
        newest_skeet ||= posted_at # this will just be set to the first item (newest's) post date
        if posted_at < Time.now-POST_HISTORY
          # is old - delete
          uri = post_is_reskeet ? post.post.viewer.repost : post.post.uri
          Rails.logger.debug "\tRemoving old #{post_is_reskeet ? 'reskeet' : 'skeet'} at URI #{uri}..."
          did, nsid, record_key = uri.delete_prefix("at://").split("/")
          verify_tokens
          make_request("#{@base_url}/com.atproto.repo.deleteRecord", body: { repo: did, collection: nsid, rkey: record_key })
        elsif newest_skeet >= Time.now-1.week # only store skeets if I've been active over there recently
          # is less old - keep
          skeets << post
        end

      end

    rescue => exception
      ErrorMailer.background_error('caching skeets', exception).deliver_now
      skeets = []
    end
    Rails.cache.write('skeets', skeets)
  end

  private


  # Makes a request to the API.
  def make_request(url, body: {}, params: {}, type: 'POST', auth_token: true, content_type: "application/json")
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
      token = auth_token.is_a?(String) ? auth_token : @token
      request["Authorization"] = "Bearer #{token}"
    end

    request.body = body.is_a?(Hash) ? body.to_json : body if body.present?

    response = http.request(request)
    raise "#{response.code} response - #{response.body}" unless response.code.to_s.start_with?("2")

    response.content_type == "application/json" ? JSON.parse(response.body) : response.body
  end

  # Generate tokens given an account identifier and app password.
  def generate_tokens
    response_body = make_request("#{@base_url}/com.atproto.server.createSession", body: { identifier: Rails.application.credentials.bluesky[:username], password: Rails.application.credentials.bluesky[:password] }, auth_token: false)
    process_tokens(response_body)
    store_token_data(response_body)
  end

  # Regenerates expired tokens with the refresh token.
  def perform_token_refresh
    response_body = make_request("#{@base_url}/com.atproto.server.refreshSession", auth_token: @renewal_token)
    process_tokens(response_body)
    store_token_data(response_body)
  end

  # Makes sure a token is set and the token has not expired.
  # If this is the first request, we'll generate the token.
  # If the token expired, we'll refresh it.
  def verify_tokens
    if @token.nil?
      generate_tokens
    elsif @token_expires_at < Time.now.utc + 60
      perform_token_refresh
    end
  end

  # Given the response body of generating or refreshing token, this pulls out
  # and stores the bits of information we care about.
  def process_tokens(response_body)
    @token = response_body["accessJwt"]
    @renewal_token = response_body["refreshJwt"]
    @user_did = response_body["did"]
    @token_expires_at = Time.at(JSON.parse(Base64.decode64(response_body["accessJwt"].split(".")[1]))["exp"]).utc
  end

  # Stores the token info for use later, else we'll have to generate the token
  # for every instance of this class.
  # Assumes the cached info is stored in the Rails cache store.
  def store_token_data(data)
    Rails.cache.write(@token_cache, data)
  end

end
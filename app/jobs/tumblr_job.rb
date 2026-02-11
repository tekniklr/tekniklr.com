class TumblrJob < ApplicationJob

  # delete old tumblr posts and update cache of the newest one shown on the
  # front page
  def perform
    Rails.logger.debug "Removing old tumblr posts..."
    begin
      Tumblr.configure do |config|
        config.consumer_key = Rails.application.credentials.tumblr[:consumer_key]
        config.consumer_secret = Rails.application.credentials.tumblr[:consumer_secret]
        config.oauth_token = Rails.application.credentials.tumblr[:oauth_token]
        config.oauth_token_secret = Rails.application.credentials.tumblr[:oauth_token_secret]
      end
      client = Tumblr::Client.new
      # grab just 30 old posts at a time to avoid hitting any API limits
      old_posts = client.posts('tekniklr.tumblr.com', before: (Time.now-TUMBLR_HISTORY).to_i, sort: 'asc', limit: 30)
      old_posts["posts"].each do |post|
        client.delete('tekniklr.tumblr.com', post["id"])
      end
      newest_post = client.posts('tekniklr.tumblr.com', sort: 'desc', limit: 1)
      unless newest_post.posts.empty?
        post = newest_post.posts.first
        photos = []
        if post['photos']
          post['photos'].each do |photo|
            if photo.alt_sizes.any?{|s| s.width == 640}
              photos << photo.alt_sizes.select{|s| s.width == 640}.first.url
            else
              photos << photo.original_size.url
            end
          end
        end
        parsed_post = {
          url: post['post_url'],
          time: Time.parse(post['date']),
          photos: photos,
          body: post['body'] ? post['body'] : post['caption'],
          reblog: (post['trail'].first.blog.name == 'tekniklr') ? false : post['trail'].first.blog.name

        }
        Rails.cache.write('tumblr_post', parsed_post)
      end
    rescue => exception
      ErrorMailer.background_error('removing old tumblr posts', exception).deliver_now
    end
  end

end
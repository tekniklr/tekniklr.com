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

      # delete 30 old posts at a time to avoid hitting any API limits
      old_posts = client.posts('tekniklr.tumblr.com', before: (Time.now-TUMBLR_HISTORY).to_i, sort: 'asc', limit: 30)
      old_posts['posts'].each do |post|
        Rails.logger.debug "\tdeleting post with id #{post['id']}..."
        client.delete('tekniklr.tumblr.com', post['id'])
      end

      # cache data from newest post(s) to display on home page
      num_posts = 1
      Rails.logger.debug "Fetching #{num_posts} newest tumblr posts..."
      newest_posts = client.posts('tekniklr.tumblr.com', sort: 'desc', limit: num_posts)
      posts = []
      unless newest_posts.posts.empty?
        newest_posts.posts.each do |post|
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
          video = false
          if post['video_url']
            if post['player'] && post['player'].any?{|p| p.width == 500}
              video = post['player'].select{|p| p.width == 500}.first.embed_code
            end
          end
          reblog = false
          unless post['trail'].empty?
            (post['trail'].first.blog.name != 'tekniklr') and reblog = post['trail'].first.blog.name
          end
          parsed_post = {
            id:     post['id'],
            url:    post['post_url'],
            time:   Time.parse(post['date']),
            photos: photos,
            video:  video,
            body:   post['body'] ? post['body'] : post['caption'],
            reblog: reblog,
            tags:   post['tags']
          }
          posts << parsed_post
        end
        Rails.cache.write('tumblr', posts)
      end
    rescue => exception
      ErrorMailer.background_error('removing old tumblr posts', exception).deliver_now
    end
  end

end
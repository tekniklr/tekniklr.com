class TumblrJob < ApplicationJob

  # I've been purging old local wordpress posts for a long time, but these all
  # come from tumblr, where they've stayed unless manually removed. until now.
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
      old_posts = client.posts('tekniklr.tumblr.com', before: (Time.now-BLOG_HISTORY).to_i, sort: 'asc', limit: 30)
      old_posts["posts"].each do |post|
        client.delete('tekniklr.tumblr.com', post["id"])
      end
    rescue => exception
      ErrorMailer.background_error('removing old tumblr posts', exception).deliver_now
    end
  end

end
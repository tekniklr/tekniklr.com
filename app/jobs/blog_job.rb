class BlogJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching newest blog post from database, purging duplicate posts"
    post = nil
    begin
      Blog.remove_duplicates!
      Blog.remove_old!
      post = Blog.posts.published.sorted.first
      if post.post_date.to_datetime < Time.now-1.week
        # if I haven't posted in a while, don't show old shit
        post = nil
      end
    rescue  => exception
      ErrorMailer.background_error('caching/purging blog posts', exception).deliver_now
      post = nil
    end
    unless post.blank?
      Rails.cache.write('blog_posts', post)
    end
  end
  
end
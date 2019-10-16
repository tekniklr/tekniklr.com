class BlogJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching newest blog post from database, purging duplicate posts"
    begin
      Blog.remove_duplicates!
      Blog.remove_old!
      post = Blog.posts.published.sorted.first
    rescue Mysql2::Error::ConnectionError
      Rails.logger.debug "Unable to connect to database!"
      post = nil
    end
    Rails.cache.write('blog_posts', post)
  end
  
end
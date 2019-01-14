class BlogJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching newest blog post from database, purging duplicate posts"
    Blog.remove_duplicates
    Blog.remove_old!
    post = Blog.posts.published.sorted.first
    Rails.cache.write('blog_posts', post)
  end
  
end
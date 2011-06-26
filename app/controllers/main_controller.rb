class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }

  def index
    @blog_post ||= Rails.cache.fetch('blog_post', :expires_in => 15.minutes) { get_blog_post }
    @tweets    ||= Rails.cache.fetch('recent_tweets', :expires_in => 5.minutes) { Tweet.limit(3) }
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

  def navigation
    page_title 'navigation'
  end

  # https://github.com/rails/rails/issues/671
  def routing_error
    render '404', :status => 404
  end

  private
  
  def get_blog_post
    if File.exists?('/usr/local/bin/php')
      post = `/usr/local/bin/php public/wpblog/wp-content/themes/tekniklr.com/newest.php`
    elsif File.exists?('/usr/bin/php')
      post = `/usr/bin/php public/wpblog/wp-content/themes/tekniklr.com/newest.php`
    else
      post = ''
    end
  end

end

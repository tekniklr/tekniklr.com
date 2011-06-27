class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @blog_post ||= Rails.cache.fetch('blog_post', :expires_in => 15.minutes) { get_blog_post }
    @tweets    ||= Tweet.limit(3)
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

  def navigation
    page_title 'navigation'
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

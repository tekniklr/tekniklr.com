class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }

  def index
    @blog_post ||= get_blog_post
    @tweets    ||= Tweet.limit(3)
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

  # https://github.com/rails/rails/issues/671
  def routing_error
    render '404', :status => 404
  end

  private
  
  def get_blog_post
    post = `php public/wpblog/wp-content/themes/tekniklr.com/newest.php`
  end

end

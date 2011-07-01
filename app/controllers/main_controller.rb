class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @post   ||= Rails.cache.fetch('blog_post', :expires_in => 2.hours) { get_blog_post }
    @tweets ||= Tweet.limit(3)
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

  def navigation
    page_title 'navigation'
  end

  private
  
  def get_blog_post
    require 'rss'
    rss = RSS::Parser.parse(open('http://tekniklr.com/wpblog/feed/').read, false)
    rss.items.first
  end

end

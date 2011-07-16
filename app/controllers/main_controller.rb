class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @post        = Rails.cache.fetch('blog_post', :expires_in => 1.hour) { get_blog_post }
    @tweets      = Tweet.limit(3)
    @consumption = Rails.cache.fetch('consuming', :expires_in => 2.hours) { get_all_consuming}
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
    begin
      rss = RSS::Parser.parse(open('http://tekniklr.com/wpblog/feed/').read, false)
      rss.items.first
    rescue
      ''
    end
  end

  def get_all_consuming
    require 'rss'
    begin
      rss = RSS::Parser.parse(open('http://www.allconsuming.net/person/tekniklr/rss').read, false)
      rss.items[1..7]
    rescue
      ''
    end
  end

end

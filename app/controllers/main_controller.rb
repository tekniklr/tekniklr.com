class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @tweets      = Tweet.limit(50).reject{|t| !t.tw_reply_username.blank?}.first(3)
    @post        = Rails.cache.fetch('blog_post', :expires_in => 10.minutes) { get_blog_post }
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
    logger.debug "Fetching blog post from RSS..."
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://tekniklr.com/wpblog/feed/')
      feed.entries.reject{|e| e.title =~ /^Transmissions from/}.first
    rescue
      ''
    end
  end

  def get_all_consuming
    logger.debug "Fetching all consuming from RSS..."
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://www.allconsuming.net/person/tekniklr/rss')
      feed.entries[0..6]
    rescue
      ''
    end
  end

end

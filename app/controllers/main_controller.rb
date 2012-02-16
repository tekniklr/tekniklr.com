class MainController < ApplicationController
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @tweets      = Tweet.limit(50).reject{|t| !t.tw_reply_username.blank?}.first(3)
    
    @post        = Rails.cache.fetch('blog_post', :expires_in => 10.minutes) { get_blog_post }
    
    @getglue_expiry   = Rails.cache.read('getglue_expiry')
    @getglue          = Rails.cache.read('getglue')
    if @getglue_expiry.nil? || Time.now > @getglue_expiry
      @getglue_expiry = Rails.cache.write('getglue_expiry', (Time.now + 1.hours))
      require 'delayed_job/getglue_job'
      Delayed::Job.enqueue(GetglueJob.new)
    end
    
    @bookmarks   = Rails.cache.fetch('delicious', :expires_in => 2.hours) { get_delicious }
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

  def get_delicious
    logger.debug "Fetching delicious bookmarks from RSS..."
    begin
      feed = Feedzirra::Feed.fetch_and_parse('http://feeds.delicious.com/v2/rss/tekniklr?count=4')
      feed.entries[0..4]
    rescue
      ''
    end
  end

end

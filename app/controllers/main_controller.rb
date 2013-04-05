class MainController < ApplicationController
  caches_action   :acknowledgments, :layout => false
  caches_action   :navigation,      :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @tumblr_expiry   = Rails.cache.read('tumblr_expiry')
    @tumblr_posts    = Rails.cache.read('tumblr_posts')
    if @tumblr_expiry.nil? || Time.now > @tumblr_expiry
      @tumblr_expiry = Rails.cache.write('tumblr_expiry', (Time.now + 2.hours))
      require 'delayed_job/tumblr_job'
      Delayed::Job.enqueue(DelayedJob::TumblrJob.new)
    end
    
    @gaming_expiry   = Rails.cache.read('gaming_expiry')
    @gaming          = Rails.cache.read('gaming')
    if @gaming_expiry.nil? || Time.now > @gaming_expiry
      @gaming_expiry = Rails.cache.write('gaming_expiry', (Time.now + 3.hours))
      require 'delayed_job/gaming_job'
      Delayed::Job.enqueue(DelayedJob::GamingJob.new)
    end
    
    @bookmarks   = Rails.cache.fetch('delicious', :expires_in => 42.minutes) { get_delicious }
    
    @lastfm_expiry   = Rails.cache.read('lastfm_expiry')
    @lastfm          = Rails.cache.read('lastfm')
    if @lastfm_expiry.nil? || Time.now > @lastfm_expiry
      @lastfm_expiry = Rails.cache.write('lastfm_expiry', (Time.now + 36.minutes))
      require 'delayed_job/lastfm_job'
      Delayed::Job.enqueue(DelayedJob::LastfmJob.new)
    end
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

  def navigation
    page_title 'navigation'
  end

  private

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

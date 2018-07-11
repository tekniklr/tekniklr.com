class MainController < ApplicationController

  def index
    @tweet_expiry    = Rails.cache.read('tweet_expiry')
    @tweets          = Rails.cache.read('tweets')
    if @tweet_expiry.nil? || Time.now > @tweet_expiry
      @tweet_expiry  = Rails.cache.write('tweet_expiry', (Time.now + 12.minutes))
      Delayed::Job.enqueue(TwitterJob.new)
    end

    @blog_expiry   = Rails.cache.read('blog_expiry')
    @blog_post     = Rails.cache.read('blog_posts')
    if @blog_expiry.nil? || Time.now > @blog_expiry
      @blog_expiry = Rails.cache.write('blog_expiry', (Time.now + 12.minutes))
      Delayed::Job.enqueue(BlogJob.new)
    end
    
    @flickr_expiry   = Rails.cache.read('flickr_expiry')
    @flickr_photos   = Rails.cache.read('flickr_photos')
    if @flickr_expiry.nil? || Time.now > @flickr_expiry
      @flickr_expiry = Rails.cache.write('flickr_expiry', (Time.now + 1.hours))
      Delayed::Job.enqueue(FlickrJob.new)
    end

    @goodreads_expiry   = Rails.cache.read('goodreads_expiry')
    @goodreads          = Rails.cache.read('goodreads')
    if @goodreads_expiry.nil? || Time.now > @goodreads_expiry
      @goodreads_expiry = Rails.cache.write('goodreads_expiry', (Time.now + 2.hours))
      Delayed::Job.enqueue(GoodreadsJob.new)
    end

    @lastfm_expiry   = Rails.cache.read('lastfm_expiry')
    @lastfm          = Rails.cache.read('lastfm')
    if @lastfm_expiry.nil? || Time.now > @lastfm_expiry
      @lastfm_expiry = Rails.cache.write('lastfm_expiry', (Time.now + 12.minutes))
      Delayed::Job.enqueue(LastfmJob.new)
    end

    @gaming_expiry   = Rails.cache.read('gaming_expiry')
    @gaming          = Rails.cache.read('gaming')
    if @gaming_expiry.nil? || Time.now > @gaming_expiry
      @gaming_expiry = Rails.cache.write('gaming_expiry', (Time.now + 2.hours))
      Delayed::Job.enqueue(GamingJob.new)
    end

  end

  def colophon
    page_title 'colophon'
  end

end

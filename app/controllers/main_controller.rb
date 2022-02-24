class MainController < ApplicationController

  def index

    @tweet_expiry    = Rails.cache.read('tweet_expiry')
    @tweets          = Rails.cache.read('tweets')
    if @tweet_expiry.nil? || Time.now > @tweet_expiry
      @tweet_expiry  = Rails.cache.write('tweet_expiry', (Time.now + 12.minutes))
      TwitterJob.perform_later
    end

    @blog_expiry   = Rails.cache.read('blog_expiry')
    @blog_post     = Rails.cache.read('blog_posts')
    if @blog_expiry.nil? || Time.now > @blog_expiry
      @blog_expiry = Rails.cache.write('blog_expiry', (Time.now + 12.minutes))
      BlogJob.perform_later
    end

    @goodreads_expiry   = Rails.cache.read('goodreads_expiry')
    @goodreads          = Rails.cache.read('goodreads')
    if @goodreads_expiry.nil? || Time.now > @goodreads_expiry
      @goodreads_expiry = Rails.cache.write('goodreads_expiry', (Time.now + 2.hours))
      GoodreadsJob.perform_later
    end

    @lastfm_expiry   = Rails.cache.read('lastfm_expiry')
    @lastfm          = Rails.cache.read('lastfm')
    if @lastfm_expiry.nil? || Time.now > @lastfm_expiry
      @lastfm_expiry = Rails.cache.write('lastfm_expiry', (Time.now + 12.minutes))
      LastfmJob.perform_later
    end

    @gaming_expiry   = Rails.cache.read('gaming_expiry')
    @gaming          = Rails.cache.read('gaming')
    if @gaming_expiry.nil? || Time.now > @gaming_expiry
      @gaming_expiry = Rails.cache.write('gaming_expiry', (Time.now + 2.hours))
      GamingJob.perform_later
    end

  end

  def colophon
    page_title 'colophon'
  end

end

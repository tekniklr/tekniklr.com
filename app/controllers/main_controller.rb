class MainController < ApplicationController

  def index

    @tumblr_expiry   = Rails.cache.read('tumblr_expiry')
    @tumblr          = Rails.cache.read('tumblr')
    if @tumblr_expiry.nil? || Time.now > @tumblr_expiry
      @tumblr_expiry = Rails.cache.write('tumblr_expiry', (Time.now + 12.minutes))
      TumblrJob.perform_later
    end

    @skeet_expiry    = Rails.cache.read('skeet_expiry')
    @skeets          = Rails.cache.read('skeets')
    if @skeet_expiry.nil? || Time.now > @skeet_expiry
      @skeet_expiry  = Rails.cache.write('skeet_expiry', (Time.now + 12.minutes))
      BlueskyJob.perform_later
    end

    @toot_expiry    = Rails.cache.read('toot_expiry')
    @toots          = Rails.cache.read('toots')
    if @toot_expiry.nil? || Time.now > @toot_expiry
      @toot_expiry  = Rails.cache.write('toot_expiry', (Time.now + 12.minutes))
      MastodonJob.perform_later
    end

    @gaming_expiry   = Rails.cache.read('gaming_expiry')
    @gaming          = Rails.cache.read('gaming')
    if @gaming_expiry.nil? || Time.now > @gaming_expiry
      @gaming_expiry = Rails.cache.write('gaming_expiry', (Time.now + 2.hours))
      GamingJob.perform_later
    end

    @letterboxd_expiry   = Rails.cache.read('letterboxd_expiry')
    @letterboxd          = Rails.cache.read('letterboxd')
    if @letterboxd_expiry.nil? || Time.now > @letterboxd_expiry
      @letterboxd_expiry = Rails.cache.write('letterboxd_expiry', (Time.now + 2.hours))
      LetterboxdJob.perform_later
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

  end

  def colophon
    page_title 'colophon'
  end

end

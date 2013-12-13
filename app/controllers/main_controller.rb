class MainController < ApplicationController
  caches_action   :colophon, :layout => false
  caches_action   :routing_error,   :layout => false

  def index
    @tumblr_expiry   = Rails.cache.read('tumblr_expiry')
    @tumblr_posts    = Rails.cache.read('tumblr_posts')
    if @tumblr_expiry.nil? || Time.now > @tumblr_expiry
      @tumblr_expiry = Rails.cache.write('tumblr_expiry', (Time.now + 2.hours))
      require 'delayed_job/tumblr_job'
      Delayed::Job.enqueue(DelayedJob::TumblrJob.new)
    end
    
    @delicious_expiry   = Rails.cache.read('delicious_expiry')
    @delicious          = Rails.cache.read('delicious')
    if @delicious_expiry.nil? || Time.now > @delicious_expiry
      @delicious_expiry = Rails.cache.write('delicious_expiry', (Time.now + 3.hours))
      require 'delayed_job/delicious_job'
      Delayed::Job.enqueue(DelayedJob::DeliciousJob.new)
    end
    
    @flickr_expiry   = Rails.cache.read('flickr_expiry')
    @flickr_photos   = Rails.cache.read('flickr_photos')
    if @flickr_expiry.nil? || Time.now > @flickr_expiry || @flickr_photos.blank?
      @flickr_expiry = Rails.cache.write('flickr_expiry', (Time.now + 6.hours))
      require 'delayed_job/flickr_job'
      Delayed::Job.enqueue(DelayedJob::FlickrJob.new)
    end
  end

  def colophon
    page_title 'colophon'
  end

end

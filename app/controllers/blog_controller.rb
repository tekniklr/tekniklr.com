class BlogController < ApplicationController

  def index
    @wpblog = true
    @tumblr_expiry   = Rails.cache.read('tumblr_expiry')
    @tumblr_posts    = Rails.cache.read('tumblr_posts')
    if @tumblr_expiry.nil? || Time.now > @tumblr_expiry
      @tumblr_expiry = Rails.cache.write('tumblr_expiry', (Time.now + 2.hours))
      require 'delayed_job/tumblr_job'
      Delayed::Job.enqueue(DelayedJob::TumblrJob.new)
    end
  end

end

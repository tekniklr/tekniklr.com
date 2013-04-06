class FlickrController < ApplicationController
  before_filter   { |c| c.page_title 'pictures', false }

  def index
    @flickr_expiry   = Rails.cache.read('flickr_expiry')
    @flickr_photos   = Rails.cache.read('flickr_photos')
    if @flickr_expiry.nil? || Time.now > @flickr_expiry || @flickr_photos.blank?
      @flickr_expiry = Rails.cache.write('flickr_expiry', (Time.now + 3.hours))
      require 'delayed_job/flickr_job'
      Delayed::Job.enqueue(DelayedJob::FlickrJob.new)
    end
  end

end

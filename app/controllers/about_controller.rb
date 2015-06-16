class AboutController < ApplicationController
  before_filter   { |c| c.page_title 'about Teri', false }
  
  def index
    collect_facets
    build_favorites
  end
  
  private
  
  def collect_facets
    @gravatar_id ||= Digest::MD5::hexdigest(EMAIL).downcase
    @who         ||= Facet.find_by_slug('who')
    @location    ||= Facet.find_by_slug('location')
    @interests   ||= Facet.find_by_slug('interests')
    @twitter     ||= Facet.find_by_slug('twitter')
    @messaging   ||= Facet.find_by_slug('messaging')
    @about_links ||= Link.get_visible
  end
  
  def build_favorites
    @favorites = Favorite.all
    @things_expiry = Rails.cache.read('things_expiry')
    @things         = Rails.cache.read('things_amazon')
    if @things_expiry.nil? || Time.now > @things_expiry
      @things_expiry = Rails.cache.write('things_expiry', (Time.now + 6.hours))
      require 'delayed_job/things_job'
      Delayed::Job.enqueue(DelayedJob::ThingsJob.new)
    end
  end
  
end

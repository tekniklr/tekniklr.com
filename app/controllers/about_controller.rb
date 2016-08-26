class AboutController < ApplicationController
  before_action   { |c| c.page_title 'about', false }
  
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
    @things_fetched = Rails.cache.read('things_fetched')
    @things         = Rails.cache.read('things_amazon')
    if !@things_fetched
      @things_fetched = Rails.cache.write('things_fetched', true)
      require 'delayed_job/things_job'
      Delayed::Job.enqueue(DelayedJob::ThingsJob.new)
    end
  end
  
end

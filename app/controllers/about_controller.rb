class AboutController < ApplicationController
  before_filter   { |c| c.page_title 'about Teri', false }
  caches_action   :index, :layout => false, :expires_in => 15.minutes
  
  def index
    collect_facets
    build_favorites
  end
  
  private
  
  def collect_facets
    @gravatar_id ||= Digest::MD5::hexdigest(EMAIL).downcase
    @who         ||= Facet.find_by_slug('who')
    @messaging   ||= Facet.find_by_slug('messaging')
    @location    ||= Facet.find_by_slug('location')
    @tech        ||= Facet.find_by_slug('tech')
    @interests   ||= Facet.find_by_slug('interests')
    @about_links ||= Link.get_visible
  end
  
  def build_favorites
    @favorites = Favorite.all
    @things_fetched = Rails.cache.read('things_fetched')
    @things         = Rails.cache.read('things_amazon')
    if !@things_fetched
      @things_fetched = Rails.cache.write('things_fetched', true)
      require 'delayed_job/things_job'
      Delayed::Job.enqueue(DelayedJob::ThingsJob.new(@favorites))
    end
  end
  
end

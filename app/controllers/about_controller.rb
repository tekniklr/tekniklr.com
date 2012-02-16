class AboutController < ApplicationController
  before_filter   { |c| c.page_title 'about Teri', false }
  caches_action   :index, :layout => false, :expires_in => 1.hour
  
  def index
    collect_facets
    build_favorites
  end
  
  private
  
  def collect_facets
    @gravatar_id ||= Digest::MD5::hexdigest(EMAIL).downcase
    @twitter     ||= Facet.find_by_slug('twitter')
    @who         ||= Facet.find_by_slug('who')
    @messaging   ||= Facet.find_by_slug('messaging')
    @definition  ||= Facet.find_by_slug('definition')
    @location    ||= Facet.find_by_slug('location')
    @tech        ||= Facet.find_by_slug('tech')
    @interests   ||= Facet.find_by_slug('interests')
    @about_links ||= Link.get_visible
  end
  
  def build_favorites
    @favorites = Favorite.all
    @things_fetched = Rails.cache.read('things_fetched')
    @things         = Rails.cache.read('things_amazon')
    if !@things_fetched && @things.nil?
      @things_fetched = Rails.cache.write('things_fetched', true)
      require 'things_job'
      Delayed::Job.enqueue(ThingsJob.new(@favorites))
    end
  end
  
end

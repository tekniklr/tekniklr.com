class AboutController < ApplicationController
  before_filter   { |c| c.page_title 'about Teri', false }
  before_filter   :collect_facets
  caches_action   :index, :layout => false
  
  def index
    @footnote    = '<p>provided in the <a href="http://microformats.org/wiki/hcard">hcard</a> <a href="http://microformats.org/">microformat</a></p>' 
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
    @favorites   ||= Favorite.all
  end
  
end

class AboutController < ApplicationController
  before_filter   { |c| c.page_title 'about Teri' }
  before_filter   :collect_facets
  
  def index
  end
  
  private
  
  def collect_facets
    @definition  ||= Facet.find_by_slug('definition')
    @location    ||= Facet.find_by_slug('location')
    @tech        ||= Facet.find_by_slug('tech')
    @interests   ||= Facet.find_by_slug('interests')
    @about_links ||= Link.get_visible
    @favorites   ||= Favorite.all
  end
  
end

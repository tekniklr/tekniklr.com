class AboutController < ApplicationController
  before_action   { |c| c.page_title 'about', false }
  
  def index
    collect_facets
    build_favorites
  end
  
  private
  
  def collect_facets
    @gravatar_id ||= Digest::MD5::hexdigest(EMAIL).downcase
    @interests   ||= Facet.find_by_slug('interests')
    @about_links ||= Link.get_visible
  end
  
  def build_favorites
    @favorites = Favorite.with_things
  end
  
end

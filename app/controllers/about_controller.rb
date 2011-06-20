class AboutController < ApplicationController
  before_filter   { |c| c.page_title 'about Teri' }
  before_filter   :collect_facets
  
  def index
  end
  
  private
  
  def collect_facets
    @about_links ||= Link.get_visible
    @favorites   ||= Favorite.all
  end
  
end

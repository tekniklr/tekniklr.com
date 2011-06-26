class ResumeController < ApplicationController
  before_filter  { |c| c.page_title 'resume' }
  before_filter   :collect_facets
  caches_action   :index, :layout => false
  caches_action   :clean

  def index
  end
  
  def clean
    render        :index, :layout   => 'simple.html'
  end

  private
  
  def collect_facets
    @experiences  ||= Experience.limit(4)
    @tech         ||= Facet.find_by_slug('tech')
    @fun_dev      ||= Facet.find_by_slug('fun_dev')
    @publications ||= Facet.find_by_slug('publications')
    @education    ||= Facet.find_by_slug('education')
    @activities   ||= Facet.find_by_slug('activities')
  end

end

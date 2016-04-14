class ResumeController < ApplicationController
  before_filter   :is_admin?
  before_filter  { |c| c.page_title 'resume' }

  def index
    collect_facets
  end
  
  def clean
    collect_facets
    render        :layout   => 'simple.html'
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

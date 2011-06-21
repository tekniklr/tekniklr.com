class ResumeController < ApplicationController
  before_filter  { |c| c.page_title 'resume' }
  before_filter   :collect_facets

  def index
  end

  private
  
  def collect_facets
    @experiences  ||= Experience.all
    @tech         ||= Facet.find_by_slug('tech')
    @fun_dev      ||= Facet.find_by_slug('fun_dev')
    @publications ||= Facet.find_by_slug('publications')
    @education    ||= Facet.find_by_slug('education')
    @activities   ||= Facet.find_by_slug('activities')
  end

end

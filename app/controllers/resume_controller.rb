class ResumeController < ApplicationController
  before_action   :is_admin?
  before_action  { |c| c.page_title 'resume' }

  def index
    collect_facets
  end
  
  def clean
    collect_facets
    render        layout: 'simple'
  end

  private
  
  def collect_facets
    @resume_name  ||= Facet.find_by_slug('resume_name')
    @resume_email ||= Facet.find_by_slug('resume_email')
    @resume_url   ||= Facet.find_by_slug('resume_url')
    @experiences  ||= Experience.limit(4)
    @tech         ||= Facet.find_by_slug('tech')
    @fun_dev      ||= Facet.find_by_slug('fun_dev')
    @publications ||= Facet.find_by_slug('publications')
    @education    ||= Facet.find_by_slug('education')
    @activities   ||= Facet.find_by_slug('activities')
  end

end

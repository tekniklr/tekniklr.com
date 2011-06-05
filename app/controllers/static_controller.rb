class StaticController < ApplicationController
  before_filter :set_wpblog_variables
  caches_page :index, :headincmeta_partial, :header_partial, :navigation_partial, :footer_partial, :pageend_partial
  
  def headincmeta_partial
    render :partial => 'layouts/static/headincmeta'
  end
  
  def header_partial
    render :partial => 'layouts/static/header'
  end
  
  def navigation_partial
    render :partial => 'layouts/static/navigation'
  end
  
  def footer_partial
    render :partial => 'layouts/static/footer'
  end
  
  def pageend_partial
    render :partial => 'layouts/static/pageend'
  end
  
  private
  
  def set_wpblog_variables
    @wpblog = true
  end
  
end
# this is so that wordpress can load its layout from rails
class StaticController < ApplicationController
  before_action :set_wpblog_variables
  
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
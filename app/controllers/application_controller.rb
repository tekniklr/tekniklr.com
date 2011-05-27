class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  protected
  
  def page_title(title)
    @page_title = title ? title : nil
  end
  
end

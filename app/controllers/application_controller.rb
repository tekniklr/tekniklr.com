class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  helper_method :logged_in?
  
  protected
  
  def page_title(title)
    @page_title = title ? title : nil
  end
  
  def logged_in?
    session[:user_id]
  end
  
  def current_user  
    @current_user ||= User.find(session[:user_id]) if session[:user_id]  
  end
  
end

require 'exceptions'
class ApplicationController < ActionController::Base
  include Exceptions
  protect_from_forgery
  
  rescue_from Exceptions::UserNotAuthorized, :with => :user_not_authorized
  
  helper_method :current_user
  helper_method :logged_in?
  
  before_filter   :get_links
  
  protected
  
  def page_title(title, display = false)
    @page_title = title ? title : nil
    @title_display = display
  end
  
  def logged_in?
    session[:user_id]
  end
  
  def current_user  
    @current_user ||= User.find(session[:user_id]) if session[:user_id]  
  end
  
  def is_admin?
    logged_in? or raise UserNotAuthorized
  end
  
  def get_links
    @links ||= Link.all
  end
  
  private
  
  def user_not_authorized
    flash[:error] = "You do not have access to this page."
    redirect_to root_url
  end
  
end

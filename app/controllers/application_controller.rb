require 'exceptions'
class ApplicationController < ActionController::Base
  include Exceptions
  protect_from_forgery
  
  rescue_from Exceptions::UserNotAuthorized, :with => :user_not_authorized
  
  helper_method :current_user
  helper_method :logged_in?
  
  before_filter   :get_links
  
  # https://github.com/rails/rails/issues/671
  def routing_error
    # This is really lame but passenger was crashing in such a way as to show 404
    # pages on valid requests. Trying to catch those.
    request.path == '' and return redirect_to root_url
    request.path == '/' and return redirect_to root_url
    request.path == '/about' and return redirect_to about_url
    request.path == '/resume' and return redirect_to resume_url
    request.path == '/acknowledgments' and return redirect_to acknowledgments_url
    # rails shouldn't even touch wordpress, but it sometimes was.
    request.path.match(/\/wpblog\//) and return redirect_to request.path
    
    # ok, it _really_ was not found.
    respond_to do |format|
      format.html { render '404', :status => 404 }
      format.any  { redirect_to :action => 'routing_error', :format => 'html' }
    end
  end
  
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
    @links ||= Rails.cache.fetch('all_links') { Link.all }
  end
  
  private
  
  def user_not_authorized
    flash[:error] = "You do not have access to this page."
    redirect_to root_url
  end
  
end

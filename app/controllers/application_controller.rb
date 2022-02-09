require 'exceptions'
class ApplicationController < ActionController::Base
  include Exceptions
  protect_from_forgery with: :exception
  
  rescue_from Exceptions::UserNotAuthorized, with: :user_not_authorized
  
  helper_method  :current_user
  helper_method  :logged_in?
  
  before_action  :get_links
  before_action  :is_admin?, only: :clean_cache
  
  # https://github.com/haml/haml/issues/934
  before_action do
    Current.content_security_policy_nonce = content_security_policy_nonce
  end

  # https://github.com/rails/rails/issues/671
  def routing_error
    respond_to do |format|
      format.html { render '404', status: 404 }
      format.any  { redirect_to action: 'routing_error', format: 'html' }
    end
  end

  def clean_cache
    deleted = []
    CACHED_ITEMS.each do |item|
      if Rails.cache.delete(item)
        deleted << item
      end
    end
    flash[:notice] = "Baleeted the following cache items: #{deleted.to_sentence}"
    redirect_to root_url
  end
  
  protected

  def page_title(title, display = false)
    @page_title = title ? title : nil
    @title_display = display
  end
  
  def logged_in?
    if !current_user.blank? && !Rails.env.development? && !Rails.env.test? && !request.ssl?
      # ensure we are using SSL if already logged in
      return redirect_to "https://tekniklr.com#{request.fullpath}"
    end
    !current_user.blank?
  end
  
  def current_user  
    Current.user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def is_admin?
    logged_in? or raise UserNotAuthorized
  end
  
  private
  
  def get_links
    # config.cache_classes = false was causing this to barf in dev
    if Rails.env.development? || Rails.env.test?
      @links        = Link.all
      @social_media = Link.get_social
    else
      @links        = Rails.cache.fetch('links_all')    { Link.all }
      @social_media = Rails.cache.fetch('links_social') { Link.get_social }
    end
  end
  
  def user_not_authorized
    flash[:error] = "You do not have access to this page."
    redirect_to root_url
  end
  
end

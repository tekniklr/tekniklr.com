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
    respond_to do |format|
      format.html { render '404', :status => 404 }
      format.any  { redirect_to :action => 'routing_error', :format => 'html' }
    end
  end
  
  protected
  
  def get_amazon(item_title, item_type)
    logger.debug "Searching amazon for a/n #{item_type} called #{item_title}"
    require 'amazon/aws/search'
    begin
      resp = Amazon::AWS.item_search(
        item_type,
        {
          'Keywords'     => item_title,
          'MinimumPrice' => '0001',
          'MaximumPrice' => '29999'
        }
      )
      item = resp.item_search_response.items.item.first
      return {
        :image_url  => item.small_image.url.__val__,
        :amazon_url => item.item_links.first.item_link.first.url.__val__
      }
    rescue
      false
    end
  end
  
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
  
  private
  
  def get_links
    @links        = Link.all
    @social_media = Link.get_social
  end
  
  def user_not_authorized
    flash[:error] = "You do not have access to this page."
    redirect_to root_url
  end
  
end

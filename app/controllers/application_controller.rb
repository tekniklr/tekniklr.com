class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  def login
    logger.info "logging in"
    if wordpress_logged_in?
      session[:logged_in] = true
    else
      session[:logged_in] = false
      redirect_to '/wpblog/wp-login.php'
    end
  end
  
  def logout
    logger.info "logging out"
    session[:logged_in] = false
    reset_session
    redirect_to '/wpblog/wp-login.php?action=logout'
  end
  
  protected
  
  # this site uses wordpress for authentication
  # also, there is only one administrator - me
  def is_authenticated?
    logger.debug "session[:logged_in] = #{session[:logged_in]}"
    session[:logged_in]
  end
  
  def page_title(title)
    @page_title = title ? title : nil
  end
  
  private
  
  # stupid hack! there is a php file that includes 
  # wp-blog-header.php and simply prints "1" or "0" depending
  # on whether there is an active login session.
  def wordpress_logged_in?
    logger.info "checking wordpress authentication status"
    require "net/http"
    require "uri"
    uri = URI.parse("http://" + request.domain + "/wpblog/wp-content/themes/tekniklr.com/shemp.php")
    response = Net::HTTP.get_response(uri)
    response == 1 ? true : false
  end
  
end

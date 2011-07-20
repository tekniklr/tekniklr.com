class SessionsController < ApplicationController
  
  def login
    page_title 'login', true
  end
  
  def failure
    flash[:error] = params[:message]
    redirect_to root_url
  end
  
  def validate  
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
    user or raise UserNotAuthorized
    session[:user_id] = user.id
    flash[:notice] = 'Signed in!'
    redirect_to root_url
  end
  
  def logout  
    session[:user_id] = nil
    flash[:notice] = 'Logged out'
    redirect_to root_url  
  end
  
end

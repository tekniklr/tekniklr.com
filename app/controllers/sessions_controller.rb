class SessionsController < ApplicationController
  
  def login
    page_title 'login', true
    if Rails.env.development?
      # just log in as the first user
      user = User.first
      user or raise UserNotAuthorized
      session[:user_id] = user.id
      flash[:notice] = 'Signed in!'
      redirect_to root_url
    else
      return redirect_to 'https://tekniklr.com/login' unless request.ssl?
    end
  end
  
  def failure
    flash[:error] = params[:message]
    redirect_to root_url
  end
  
  def validate  
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid_and_enabled(auth["provider"], auth["uid", true])
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

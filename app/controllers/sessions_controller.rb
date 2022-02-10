class SessionsController < ApplicationController
  
  def login
    page_title 'login', true
    if Rails.env.development?
      # just log in as the first user
      user = User.first
      user or raise UserNotAuthorized
      signin(user)
      redirect_to root_url
    else
      return redirect_to 'https://tekniklr.com/login' unless request.ssl?
    end
  end
  
  def failure
    flash[:error] = "Error: #{params[:message]}"
    redirect_to root_url
  end
  
  def validate  
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth["provider"], uid: auth["uid"], enabled: true).first
    unless user
      logger.warn "rejecting attempted login from provider #{auth["provider"]} with uid #{auth["uid"]}"
      raise UserNotAuthorized
    end
    signin(user)
    redirect_to root_url
  end
  
  def logout  
    session[:user_id] = nil
    flash[:notice] = 'Logged out'
    redirect_to root_url  
  end
  
  private

  def signin(user)
    session[:user_id] = user.id
    flash[:notice] = "Welcome, #{user.name}"
  end

end

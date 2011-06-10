class SessionsController < ApplicationController
  
  def validate  
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
    user or raise "Not authorized"
    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!" 
  end
  
  def logout  
    session[:user_id] = nil  
    redirect_to root_url, :notice => "Signed out!"  
  end
  
end

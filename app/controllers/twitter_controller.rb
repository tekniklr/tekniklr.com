class TwitterController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'tweet management' }
  
  # GET /twitter
  def index
    @tweets = Tweet.all
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  # DELETE /links/1
  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to twitter_url }
      format.js   
    end
  end
end

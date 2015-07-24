class RecentGamesController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'recent games' }

  # GET /recent_games/new
  def new
    @recent_games = RecentGame.all
    @recent_game = RecentGame.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /recent_games
  def create
    @recent_games = RecentGame.all
    @recent_game = RecentGame.new(recent_game_params)
    respond_to do |format|
      if @recent_game.save
        Rails.cache.delete('gaming_expiry')
        format.html { redirect_to new_recent_game_url, :notice => 'Recent game was successfully added.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /recent_games/1
  def destroy
    @recent_game = RecentGame.find(params[:id])
    @recent_game.destroy
    respond_to do |format|
      Rails.cache.delete('gaming_expiry')
      format.html { redirect_to new_recent_game_url, :notice => 'Recent game was successfully baleeted.' }
    end
  end

  private

  def recent_game_params
    params.require(:recent_game).permit(:name, :platform, :started_playing, :url, :image)
  end

end

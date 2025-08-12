class RecentGamesController < ApplicationController
  before_action   :is_admin?
  before_action   { |c| c.page_title 'recent games' }

  # GET /recent_games/new
  def new
    @recent_games = RecentGame.sorted
    @recent_game = RecentGame.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /recent_games/1/edit
  def edit
    @recent_game = RecentGame.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /recent_games
  def create
    @recent_games = RecentGame.sorted
    @recent_game = RecentGame.new(recent_game_params)
    respond_to do |format|
      if @recent_game.save
        Rails.cache.delete('gaming_expiry')
        format.html { redirect_to new_recent_game_url, notice: 'Recent game was successfully added.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /recent_games/1
  def update
    @recent_game = RecentGame.find(params[:id])

    respond_to do |format|
      if @recent_game.update(recent_game_params)
        flash[:notice] = 'Recent game was successfully updated.'
        Rails.cache.delete('gaming_expiry')
        format.html { redirect_to new_recent_game_url }
        format.js
      else
        flash[:error] = 'Recent game not saved: '+@recent_game.errors.full_messages.join(', ')
        format.html { render action: "edit" }
        format.js   { render action: "update_error" }
      end
    end
  end

  # DELETE /recent_games/1
  def destroy
    @recent_game = RecentGame.find(params[:id])
    @recent_game.destroy
    respond_to do |format|
      Rails.cache.delete('gaming_expiry')
      format.html { redirect_to new_recent_game_url, notice: 'Recent game was successfully baleeted.' }
    end
  end

  private

  def recent_game_params
    params.require(:recent_game).permit(:name, :platform, :started_playing, :url, :hidden, :image)
  end

end

class TabletopGamesController < ApplicationController
  before_action   :is_admin?, except: :index
  before_action   { |c| c.page_title 'tabletop games' }

  # GET /tabletop_games
  def index
    @tabletop_games   = TabletopGame.sorted
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /tabletop_games
  def manage
    @tabletop_games = TabletopGame.sorted
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /tabletop_games/new
  def new
    @tabletop_game = TabletopGame.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /tabletop_games/1/edit
  def edit
    @tabletop_game = TabletopGame.find(params[:id])
  end

  # POST /tabletop_games
  def create
    @tabletop_game = TabletopGame.new(tabletop_game_params)
    respond_to do |format|
      if @tabletop_game.save
        Rails.cache.delete('tabletop_fetched')
        format.html { redirect_to tabletop_games_url, notice: 'TableTop game was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /tabletop_games/1
  def update
    @tabletop_game = TabletopGame.find(params[:id])
    respond_to do |format|
      if @tabletop_game.update(tabletop_game_params)
        Rails.cache.delete('tabletop_fetched')
        format.html { redirect_to tabletop_games_url, notice: 'TableTop game was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /tabletop_games/1
  def destroy
    @tabletop_game = TabletopGame.find(params[:id])
    @tabletop_game.destroy
    respond_to do |format|
      format.html { redirect_to tabletop_games_url, notice: 'TableTop game was successfully baleeted.' }
    end
  end

  private

  def tabletop_game_params
    params.require(:tabletop_game).permit(:expansions, :name, :other_info, :players, :bgg_url, :image)
  end

end

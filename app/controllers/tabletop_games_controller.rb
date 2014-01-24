class TabletopGamesController < ApplicationController
  before_filter   :is_admin?, :except => :index
  before_filter   { |c| c.page_title 'tabletop games' }
  cache_sweeper   :tabletop_game_sweeper, :only => [:create, :update, :destroy]
  caches_action   :index, :layout => false, :expires_in => 15.minutes

  # GET /tabletop_games
  def index
    @tabletop_games   = TabletopGame.all
    @tabletop_fetched = Rails.cache.read('tabletop_fetched')
    @tabletop_amazon  = Rails.cache.read('tabletop_amazon')
    if !@tabletop_fetched
      @tabletop_fetched = Rails.cache.write('tabletop_fetched', true)
      require 'delayed_job/tabletop_job'
      Delayed::Job.enqueue(DelayedJob::TabletopJob.new(@tabletop_games))
    end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /tabletop_games
  def manage
    @tabletop_games = TabletopGame.all
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
    @tabletop_game = TabletopGame.new(params[:tabletop_game])
    respond_to do |format|
      if @tabletop_game.save
        format.html { redirect_to manage_tabletop_games_url, :notice => 'TableTop game was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /tabletop_games/1
  def update
    @tabletop_game = TabletopGame.find(params[:id])
    respond_to do |format|
      if @tabletop_game.update_attributes(params[:tabletop_game])
        format.html { redirect_to manage_tabletop_games_url, :notice => 'TableTop game was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /tabletop_games/1
  def destroy
    @tabletop_game = TabletopGame.find(params[:id])
    @tabletop_game.destroy
    respond_to do |format|
      format.html { redirect_to manage_tabletop_games_url, :notice => 'TableTop game was successfully baleeted.' }
    end
  end
end

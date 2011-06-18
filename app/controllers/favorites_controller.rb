class FavoritesController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'favorite management' }
   
  # GET /favorites
  # GET /favorites.json
  def index
    @favorites = Favorite.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @favorites }
    end
  end

  # GET /favorites/1
  # GET /favorites/1.json
  def show
    @favorite = Favorite.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @favorite }
    end
  end

  # GET /favorites/new
  # GET /favorites/new.json
  def new
    @favorite = Favorite.new
    @favorite.sort = Favorite.all.count + 1
    1.upto(5) { |n| @favorite.favorite_things.build(:sort => n) }
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @favorite }
    end
  end

  # GET /favorites/1/edit
  def edit
    @favorite = Favorite.find(params[:id])
    things = @favorite.favorite_things.count
    if things < 5
      (things+1).upto(5) { |n| @favorite.favorite_things.build(:sort => n) }
    end
  end

  # POST /favorites
  # POST /favorites.json
  def create
    @favorite = Favorite.new(params[:favorite])
    respond_to do |format|
      if @favorite.save
        format.html { redirect_to @favorite, notice: 'Favorite was successfully created.' }
        format.json { render json: @favorite, status: :created, location: @favorite }
      else
        format.html { render action: "new" }
        format.json { render json: @favorite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /favorites/sort
  def sort_favorites
    params[:favorite].each_with_index do |id, index|  
      Favorite.update_all(['sort=?', index+1], ['id=?', id])
    end
    respond_to do |format|
      format.html { redirect_to favorites_url, notice: 'Favorites re-ordered.' }
      format.js   { render :nothing => true }
    end
  end

  # PUT /favorites/sort
  def sort_things
    params[:favorite_thing].each_with_index do |id, index|  
      FavoriteThing.update_all(['sort=?', index+1], ['id=?', id])
    end
    respond_to do |format|
      format.html { redirect_to favorites_url, notice: 'Favorite things re-ordered.' }
      format.js   { render :nothing => true }
    end
  end

  # PUT /favorites/1
  # PUT /favorites/1.json
  def update
    @favorite = Favorite.find(params[:id])
    respond_to do |format|
      if @favorite.update_attributes(params[:favorite])
        format.html { redirect_to @favorite, notice: 'Favorite was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @favorite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favorites/1
  # DELETE /favorites/1.json
  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy
    respond_to do |format|
      format.html { redirect_to favorites_url }
      format.json { head :ok }
    end
  end
end

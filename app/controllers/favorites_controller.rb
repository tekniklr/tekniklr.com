class FavoritesController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'favorite management' }
   
  # GET /favorites
  def index
    @favorites = Favorite.all
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /favorites/1
  def show
    @favorite = Favorite.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /favorites/new
  def new
    @favorite = Favorite.new
    @favorite.sort = Favorite.all.count + 1
    1.upto(5) { |n| @favorite.favorite_things.build(:sort => n) }
    respond_to do |format|
      format.html # new.html.erb
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
  def create
    @favorite = Favorite.new(params[:favorite])
    respond_to do |format|
      if @favorite.save
        format.html { redirect_to @favorite, notice: 'Favorite was successfully created.' }
      else
        format.html { render action: "new" }
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
  def update
    @favorite = Favorite.find(params[:id])
    respond_to do |format|
      if @favorite.update_attributes(params[:favorite])
        format.html { redirect_to @favorite, notice: 'Favorite was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /favorites/1
  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy
    respond_to do |format|
      format.html { redirect_to favorites_url }
      format.js
    end
  end
end

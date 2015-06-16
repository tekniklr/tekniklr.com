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
    1.upto(NUM_FAVS) { |n| @favorite.favorite_things.build(:sort => n) }
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /favorites/1/edit
  def edit
    @favorite = Favorite.find(params[:id])
    things = @favorite.favorite_things.count
    if things < NUM_FAVS
      (things+1).upto(NUM_FAVS) { |n| @favorite.favorite_things.build(:sort => n) }
    end
  end

  # POST /favorites
  def create
    @favorite = Favorite.new(favorite_params)
    respond_to do |format|
      if @favorite.save
        Rails.cache.delete('things_expiry')
        format.html { redirect_to @favorite, :notice => 'Favorite was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /favorites/sort
  def sort_favorites
    params[:favorite].each_with_index do |id, index|  
      Favorite.update(id, sort: index+1)
    end
    respond_to do |format|
      format.html { redirect_to favorites_url, :notice => 'Favorites re-ordered.' }
      format.js   { render :nothing => true }
    end
  end

  # PUT /favorites/sort
  def sort_things
    params[:favorite_thing].each_with_index do |id, index|  
      FavoriteThing.update(id, sort: index+1)
    end
    respond_to do |format|
      format.html { redirect_to favorites_url, :notice => 'Favorite things re-ordered.' }
      format.js   { render :nothing => true }
    end
  end

  # PUT /favorites/1
  def update
    @favorite = Favorite.find(params[:id])
    respond_to do |format|
      if @favorite.update_attributes(favorite_params)
        Rails.cache.delete('things_expiry')
        format.html { redirect_to @favorite, :notice => 'Favorite was successfully updated.' }
      else
        format.html { render :action => "edit" }
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


  private

  def favorite_params
    params.require(:favorite).permit(:favorite_type, :sort, favorite_things_attributes: [:id, :thing, :link, :sort, :_destroy])
  end
  
end

class FacetsController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'Facet management' }
  cache_sweeper   :facet_sweeper, :only => [:create, :update, :destroy]
  
  # GET /facets
  def index
    @facets = Facet.all
    @facet ||= Facet.new
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /facets/1
  def show
    @facet = Facet.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /facets/1/edit
  def edit
    @facet = Facet.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /facet
  def create
    @facet = Facet.new(params[:facet])
    respond_to do |format|
      if @facet.save
        flash[:notice] = 'Facet added.'
        format.html { redirect_to facets_url }
        format.js
      else
        flash[:error] = 'Facet not valid: '+@facet.errors.full_messages.join(', ')
        format.html { render :action => "index" }
        format.js   { render :action => "error" }
      end
    end
  end

  # PUT /facets/1
  def update
    @facet = Facet.find(params[:id])
    respond_to do |format|
      if @facet.update_attributes(params[:facet])
        flash[:notice] = 'Facet was successfully updated.'
        format.html { redirect_to facets_url }
        format.js
      else
        flash[:error] = 'Facet not saved: '+@facet.errors.full_messages.join(', ')
        format.html { render :action => "edit" }
        format.js   { render :action => "update_error" }
      end
    end
  end

  # DELETE /facets/1
  def destroy
    @facet = Facet.find(params[:id])
    @facet.destroy
    respond_to do |format|
      format.html { redirect_to facets_url }
      format.js   
    end
  end

  private

  def facet_params
    params.require(:facet).permit(:name, :slug, :value)
  end
  
end
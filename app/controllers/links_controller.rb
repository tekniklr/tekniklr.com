class LinksController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'link management' }
  
  # GET /links
  # GET /links.json
  def index
    @links = Link.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @links }
    end
  end

  # POST /links
  def create_and_update
    @links = Link.all
    @links.each do |link|
      link.update_attributes!(params[:link])
    end
    flash[:notice] = 'Links were successfully updated.'
    @newlink = Link.new(params[:newlink])
    if @newlink.save
      flash[:notice] += 'Link added.'
    end
    redirect_to links_path
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link = Link.find(params[:id])
    @link.destroy

    respond_to do |format|
      format.html { redirect_to links_url }
      format.json { head :ok }
    end
  end
end

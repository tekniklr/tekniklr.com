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
    problems = false
    if params[:links]
      @links = Link.update(params[:links].keys, params[:links].values).reject { |l| l.errors.empty? }
      if @links.empty?
        flash[:notice] = 'Links updated.'
      else
        problems = true
      end
    end
    @newlink = Link.new(params[:newlink])
    if @newlink.save
      flash[:notice] += ' Link added.'
    end
    problems ? render(:action => 'index') : redirect_to(links_url)
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

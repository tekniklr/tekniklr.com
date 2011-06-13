class LinksController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'link management' }
  
  # GET /links
  # GET /links.json
  def index
    @links = Link.all
    @link ||= Link.new
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @links }
    end
  end

  # PUT /links
  def update_all
    @links = Link.update(params[:links].keys, params[:links].values).reject { |l| l.errors.empty? }
    if @links.empty?
      flash[:notice] = 'Links updated.'
      redirect_to(links_url)
    else
      render(:action => 'index')
    end
  end

  # POST /link
  # POST /links.json
  def create
    @link = Link.new(params[:link])
    respond_to do |format|
      if @link.save
        format.html { redirect_to links_url, notice: 'Link added.' }
        format.json { render json: @link, status: :created, location: @favorite }
      else
        format.html { render action: "index" }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
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

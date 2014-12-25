class LinksController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'link management' }
  cache_sweeper   :link_sweeper, :only => [:create, :update_all, :destroy]
  
  # GET /links
  def index
    @links = Link.all
    @link ||= Link.new
    respond_to do |format|
      format.html # index.html.erb
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
  def create
    @link = Link.new(params[:link])
    respond_to do |format|
      if @link.save
        flash[:notice] = 'Link added.'
        format.html { redirect_to links_url }
        format.js   
      else
        flash[:error] = 'Link not valid: '+@link.errors.full_messages.join(', ')
        format.html { render :action => "index" }
        format.js   { render :action => "error" }
      end
    end
  end

  # DELETE /links/1
  def destroy
    @link = Link.find(params[:id])
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url }
      format.js   
    end
  end

  private

  def link_params
    params.require(:link).permit(:name, :url, :visible, :social_icon, :icon, :icon_file_name, :icon_content_type, :icon_file_size, :icon_updated_at)
  end
  
end

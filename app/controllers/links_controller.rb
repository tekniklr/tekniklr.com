class LinksController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'link management' }
  
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
      expire_fragment :controller => 'about', :action => 'index'
      expire_fragment 'header_links'
      Rails.cache.delete('all_links')
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
        expire_fragment :controller => 'about', :action => 'index'
        expire_fragment 'header_links'
        Rails.cache.delete('all_links')
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
    expire_fragment :controller => 'about', :action => 'index'
    expire_fragment 'header_links'
    Rails.cache.delete('all_links')
    respond_to do |format|
      format.html { redirect_to links_url }
      format.js   
    end
  end
end

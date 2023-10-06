class LinksController < ApplicationController
  before_action   :is_admin?
  before_action   { |c| c.page_title 'link management' }
  
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
    errors = []
    params[:links].each do |key, values|
      logger.debug "************ updating #{key} with #{values}"
      link = Link.find(key)
      unless link.update(update_links_params(values))
        logger.debug "************ failed! - #{link.errors.full_messages}"
        errors << link.errors.full_messages
      end
    end
    @links = Link.all
    if errors.empty?
      flash[:notice] = 'Links updated.'
      redirect_to(links_url)
    else
      flash[:error] = "Some links could not be updated: #{errors.flatten.to_sentence}"
      render action: :index
    end
  end

  # POST /link
  def create
    @link = Link.new(new_link_params)
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
     [:name, :url, :visible, :social_icon, :icon, :icon_file_name, :icon_content_type, :icon_file_size, :icon_updated_at]
  end

  def new_link_params
    params.require(:link).permit(*link_params)
  end
  def update_links_params(input)
    input.permit(*link_params)
  end

end

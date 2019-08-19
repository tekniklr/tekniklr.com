class ExperiencesController < ApplicationController
  before_action   :is_admin?
  before_action   { |c| c.page_title 'experience management' }
  
  # GET /experiences
  def index
    @experiences = Experience.all
    @experience ||= Experience.new
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /experiences/1
  def show
    @experience = Experience.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /experiences/1/edit
  def edit
    @experience = Experience.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /experience
  def create
    @experience = Experience.new(experience_params)
    respond_to do |format|
      if @experience.save
        flash[:notice] = 'Experience added.'
        format.html { redirect_to experiences_url }
        format.js
      else
        flash[:error] = 'Experience not valid: '+@experience.errors.full_messages.join(', ')
        format.html { render :action => "index" }
        format.js   { render :action => "error" }
      end
    end
  end

  # PUT /experiences/1
  def update
    @experience = Experience.find(params[:id])

    respond_to do |format|
      if @experience.update(experience_params)
        flash[:notice] = 'Experience was successfully updated.'
        format.html { redirect_to experiences_url }
        format.js
      else
        flash[:error] = 'Experience not saved: '+@experience.errors.full_messages.join(', ')
        format.html { render :action => "edit" }
        format.js   { render :action => "update_error" }
      end
    end
  end

  # DELETE /experiences/1
  def destroy
    @experience = Experience.find(params[:id])
    @experience.destroy
    respond_to do |format|
      format.html { redirect_to experiences_url }
      format.js   
    end
  end

  private

  def experience_params
    params.require(:experience).permit(:start_date, :end_date, :title, :affiliation, :affiliation_link, :location, :tasks)
  end
  
end

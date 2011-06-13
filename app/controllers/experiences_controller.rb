class ExperiencesController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'experience management' }
  
  # GET /experiences
  # GET /experiences.json
  def index
    @experiences = Experience.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experiences }
    end
  end

  # POST /experiences
  def create_and_update
    @experiences = Experience.all
    @experiences.each do |experience|
      experience.update_attributes!(params[:experience])
    end
    flash[:notice] = 'Experiences were successfully updated.'
    @newexp = Experience.new(params[:newexp])
    if @newexp.save
      flash[:notice] += 'Experience added.'
    end
    redirect_to experiences_path
  end

  # DELETE /experiences/1
  # DELETE /experiences/1.json
  def destroy
    @experience = Experience.find(params[:id])
    @experience.destroy

    respond_to do |format|
      format.html { redirect_to experiences_url }
      format.json { head :ok }
    end
  end
end

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
    problems = false
    if params[:experiences]
      @experiences = Experience.update(params[:experiences].keys, params[:experiences].values).reject { |e| e.errors.empty? }
      if @experiences.empty?
        flash[:notice] = 'Experiences updated.'
      else
        problems = true
      end
    else
      @experiences = Experience.all
    end
    @newexp = Experience.new(params[:newexp])
    if @newexp.save
      flash[:notice] += ' Experience added.'
    else
      problems = true
    end
    problems ? render(:action => 'index') : redirect_to(experiences_url)
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

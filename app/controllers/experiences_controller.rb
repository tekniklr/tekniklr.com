class ExperiencesController < ApplicationController
  before_filter   :is_admin?
  before_filter   { |c| c.page_title 'experience management' }
  
  # GET /experiences
  # GET /experiences.json
  def index
    @experiences = Experience.all
    @experience ||= Experience.new
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experiences }
    end
  end

  # PUT /experiences
  def update_all
    @experiences = Experience.update(params[:experiences].keys, params[:experiences].values).reject { |e| e.errors.empty? }
    if @experiences.empty?
      flash[:notice] = 'Experiences updated.'
      redirect_to(experiences_url)
    else
      render(:action => 'index')
    end
  end

  # POST /experience
  # POST /experiences.json
  def create
    @experience = Experience.new(params[:experience])
    respond_to do |format|
      if @experience.save
        format.html { redirect_to experiences_url, notice: 'Experience added.' }
        format.json { render json: @experience, status: :created, location: @experience }
      else
        format.html { render action: "index" }
        format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end
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

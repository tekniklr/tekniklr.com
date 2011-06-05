class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }

  def index
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

end

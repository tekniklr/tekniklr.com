class MainController < ApplicationController
  #before_filter  { |c| c.page_title 'home' }

  def index
    @tweets ||= Tweet.limit(3)
  end

  def acknowledgments
    page_title 'acknowledgments'
  end

  # https://github.com/rails/rails/issues/671
  def routing_error
    render '404', :status => 404
  end

end

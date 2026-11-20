class DebugController < ApplicationController
  before_action   :is_admin?
  before_action  { |c| c.page_title 'debug' }

  def index
  end

end

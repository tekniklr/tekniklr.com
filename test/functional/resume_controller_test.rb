require 'test_helper'

class ResumeControllerTest < ActionController::TestCase

  should "get index" do
    get :index
    assert_response :success
  end

end

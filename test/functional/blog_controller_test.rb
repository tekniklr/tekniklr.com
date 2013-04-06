require 'test_helper'

class BlogControllerTest < ActionController::TestCase

  should "get index" do
    get :index
    assert_response :success
  end

end

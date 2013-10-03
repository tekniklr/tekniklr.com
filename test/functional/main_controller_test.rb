require 'test_helper'

class MainControllerTest < ActionController::TestCase
  
  should "get index" do
    get :index
    assert_response :success
  end
  
  should "get colophon" do
    get :colophon
    assert_response :success
  end
  
end

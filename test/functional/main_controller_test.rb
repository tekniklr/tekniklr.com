require 'test_helper'

class MainControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should get acknowledgments" do
    get :acknowledgments
    assert_response :success
  end

  test "should get navigation" do
    get :navigation
    assert_response :success
  end
end

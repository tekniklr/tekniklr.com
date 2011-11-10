require 'test_helper'

class TwitterControllerTest < ActionController::TestCase
  
  setup do
    @user = Factory.create(:user)
  end
  
  test "should not work without login" do
    get :index
    assert_redirected_to root_url
  end
  
  test "should get index" do
    get(:index, nil, {'user_id' => @user.id})
    assert_response :success
  end
  
end
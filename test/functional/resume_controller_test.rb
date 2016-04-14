require 'test_helper'

class ResumeControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url
  end

  should "get index" do
    get(:index, nil, {'user_id' => @user.id})
    assert_response :success
  end

end

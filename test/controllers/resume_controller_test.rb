require 'test_helper'

class ResumeControllerTest < ActionController::TestCase

  setup do
    @user = FactoryBot.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url
  end

  should "get index" do
    get :index, params: {}, session: {user_id: @user.id}
    assert_response :success
  end

end

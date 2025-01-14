require "test_helper"

class CacheControllerTest < ActionController::TestCase

  setup do
    @user = FactoryBot.create(:user)
  end

  should "not allow access without login" do
    get :index
    assert_redirected_to root_url

    put :update, params: { id: 'gaming_expiry' }
    assert_redirected_to root_url
  end

  should "get index" do
    get :index, params: {}, session: {user_id: @user.id}
    assert_response :success
  end

  should "clear cache" do
    put :update, params: { id: 'gaming_expiry' }, session: {user_id: @user.id}
    assert_redirected_to cache_index_path
  end

end

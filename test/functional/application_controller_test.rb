require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  should "not clean cache unless logged in" do
    get :clean_cache
    assert_equal "You do not have access to this page.", flash[:error]
  end

  should "clean cache if logged in" do
    get(:clean_cache, nil, {'user_id' => @user.id})
    assert_match /Baleeted/, flash[:notice]
  end

end

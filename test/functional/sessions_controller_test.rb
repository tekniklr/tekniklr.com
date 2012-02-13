require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  should "get logout" do
    get :logout
    assert_redirected_to root_url
  end

end

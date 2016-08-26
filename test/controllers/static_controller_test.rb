require 'test_helper'

class StaticControllerTest < ActionController::TestCase

  should "get headincmeta" do
    get :headincmeta_partial
    assert_response :success
  end

  should "get header" do
    get :header_partial
    assert_response :success
  end

  should "get navigation" do
    get :navigation_partial
    assert_response :success
  end

  should "get footer" do
    get :footer_partial
    assert_response :success
  end

  should "get pageend" do
    get :pageend_partial
    assert_response :success
  end

end
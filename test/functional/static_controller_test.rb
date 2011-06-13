require 'test_helper'

class StaticControllerTest < ActionController::TestCase

  test "should get headincmeta" do
    get :headincmeta_partial
    assert_response :success
  end

  test "should get header" do
    get :header_partial
    assert_response :success
  end

  test "should get navigation" do
    get :navigation_partial
    assert_response :success
  end

  test "should get footer" do
    get :footer_partial
    assert_response :success
  end

  test "should get pageend" do
    get :pageend_partial
    assert_response :success
  end

end
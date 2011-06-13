require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  fixtures  :links
  
  setup do
    @link = links('twitter')
  end

  test "should not work without login" do
    get :index
    assert_redirected_to root_url

    post :create
    assert_redirected_to root_url

    put :update, id: @link.id, link: @link.attributes
    assert_redirected_to root_url

    delete :destroy, id: @link.to_param
    assert_redirected_to root_url
  end

  test "should get index" do
    get(:index, nil, {'user_id' => 1})
    assert_response :success
    assert_not_nil assigns(:links)
  end

  test "should create link" do
    assert_difference('Link.count') do
      post(:create, {:name => 'test new', :url => 'http://google.com'}, {'user_id' => 1})
    end
    assert_redirected_to link_path
  end

  test "should update link" do
    put(:update, {id: @link.to_param, link: @link.attributes}, {'user_id' => 1})
    assert_redirected_to link_path
  end

  test "should destroy link" do
    assert_difference('Link.count', -1) do
      delete(:destroy, {id: @link.to_param}, {'user_id' => 1})
    end
    assert_redirected_to links_path
  end
end

require 'test_helper'

class FacetsControllerTest < ActionController::TestCase
  fixtures  :facets
  
  setup do
    @facet = facets('skills')
  end

  test "should not work without login" do
    get :index
    assert_redirected_to root_url

    get :show, :id => @facet.to_param
    assert_redirected_to root_url

    post :create, :facet => @facet.attributes
    assert_redirected_to root_url
    
    get :edit, :id => @facet.to_param
    assert_redirected_to root_url
    
    put :update, :id => @facet.to_param, :facet => @facet.attributes
    assert_redirected_to root_url

    delete :destroy, :id => @facet.to_param
    assert_redirected_to root_url
  end

  test "should get index" do
    get(:index, nil, {'user_id' => 1})
    assert_response :success
    assert_not_nil assigns(:facets)
  end

  test "should create facet" do
    assert_difference('Facet.count') do
      post(:create, {:facet => @facet.attributes}, {'user_id' => 1})
    end
    assert_redirected_to facets_path
  end

  test "should show facet" do
    get(:show, {:id => @facet.id}, {'user_id' => 1})
    assert_response :success
  end
  
  test "should get edit" do
    get(:edit, {:id => @facet.to_param}, {'user_id' => 1})
    assert_response :success
  end

  test "should update facet" do
    put(:update, {:id => @facet.to_param, :facet => @facet.attributes}, {'user_id' => 1})
    assert_redirected_to facets_path
  end

  test "should destroy facet" do
    assert_difference('Facet.count', -1) do
      delete(:destroy, {:id => @facet.to_param}, {'user_id' => 1})
    end
    assert_redirected_to facets_path
  end
end

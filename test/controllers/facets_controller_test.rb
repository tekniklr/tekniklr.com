require 'test_helper'

class FacetsControllerTest < ActionController::TestCase
  
  setup do
    @facet = FactoryGirl.create(:facet)
    @user = FactoryGirl.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url

    get :show, params: {id: @facet.to_param}
    assert_redirected_to root_url

    post :create, params: {facet: @facet.attributes}
    assert_redirected_to root_url
    
    get :edit, params: {id: @facet.to_param}
    assert_redirected_to root_url
    
    put :update, params: {id: @facet.to_param, facet: @facet.attributes}
    assert_redirected_to root_url

    delete :destroy, params: {id: @facet.to_param}
    assert_redirected_to root_url
  end

  should "get index" do
    get :index, params: {}, session: {user_id: @user.id}
    assert_response :success
    assert_not_nil assigns(:facets)
  end

  should "create facet" do
    assert_difference('Facet.count') do
      post :create, params: {facet: @facet.attributes}, session: {user_id: @user.id}
    end
    assert_redirected_to facets_path
  end

  should "show facet" do
    get :show, params: {id: @facet.id}, session: {user_id: @user.id}
    assert_response :success
  end
  
  should "get edit" do
    get :edit, params: {id: @facet.to_param}, session: {user_id: @user.id}
    assert_response :success
  end

  should "update facet" do
    put :update, params: {id: @facet.to_param, facet: @facet.attributes}, session: {user_id: @user.id}
    assert_redirected_to facets_path
  end

  should "destroy facet" do
    assert_difference('Facet.count', -1) do
      delete :destroy, params: {id: @facet.to_param}, session: {user_id: @user.id}
    end
    assert_redirected_to facets_path
  end
end

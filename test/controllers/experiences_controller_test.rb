require 'test_helper'

class ExperiencesControllerTest < ActionController::TestCase
  
  setup do
    @experience = FactoryBot.create(:experience)
    @user = FactoryBot.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url

    get :show, params: {id: @experience}
    assert_redirected_to root_url

    post :create, params: {experience: @experience.attributes}
    assert_redirected_to root_url
    
    get :edit, params: {id: @experience}
    assert_redirected_to root_url
    
    put :update, params: {id: @experience, experience: @experience.attributes}
    assert_redirected_to root_url

    delete :destroy, params: {id: @experience}
    assert_redirected_to root_url
  end

  should "get index" do
    get :index, params: {}, session: {user_id: @user.id}
    assert_response :success
    assert_not_nil assigns(:experiences)
  end

  should "create experience" do
    assert_difference('Experience.count') do
      post :create, params: {experience: @experience.attributes}, session: {user_id: @user.id}
    end
    assert_redirected_to experiences_path
  end

  should "show experience" do
    get :show, params: {id: @experience}, session: {user_id: @user.id}
    assert_response :success
  end
  
  should "get edit" do
    get :edit, params: {id: @experience}, session: {user_id: @user.id}
    assert_response :success
  end

  should "update experience" do
    put :update, params: {id: @experience, experience: @experience.attributes}, session: {user_id: @user.id}
    assert_redirected_to experiences_path
  end

  should "destroy experience" do
    assert_difference('Experience.count', -1) do
      delete :destroy, params: {id: @experience}, session: {user_id: @user.id}
    end
    assert_redirected_to experiences_path
  end
end

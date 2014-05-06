require 'test_helper'

class ExperiencesControllerTest < ActionController::TestCase
  
  setup do
    @experience = FactoryGirl.create(:experience)
    @user = FactoryGirl.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url

    get :show, :id => @experience
    assert_redirected_to root_url

    post :create, :experience => @experience.attributes
    assert_redirected_to root_url
    
    get :edit, :id => @experience
    assert_redirected_to root_url
    
    put :update, :id => @experience, :experience => @experience.attributes
    assert_redirected_to root_url

    delete :destroy, :id => @experience
    assert_redirected_to root_url
  end

  should "get index" do
    get(:index, nil, {'user_id' => @user.id})
    assert_response :success
    assert_not_nil assigns(:experiences)
  end

  should "create experience" do
    assert_difference('Experience.count') do
      post(:create, {:experience => @experience.attributes}, {'user_id' => @user.id})
    end
    assert_redirected_to experiences_path
  end

  should "show experience" do
    get(:show, {:id => @experience}, {'user_id' => @user.id})
    assert_response :success
  end
  
  should "get edit" do
    get(:edit, {:id => @experience}, {'user_id' => @user.id})
    assert_response :success
  end

  should "update experience" do
    put(:update, {:id => @experience, :experience => @experience.attributes}, {'user_id' => @user.id})
    assert_redirected_to experiences_path
  end

  should "destroy experience" do
    assert_difference('Experience.count', -1) do
      delete(:destroy, {:id => @experience}, {'user_id' => @user.id})
    end
    assert_redirected_to experiences_path
  end
end

require 'test_helper'

class ExperiencesControllerTest < ActionController::TestCase
  
  setup do
    @experience = Factory.create(:experience)
    @user = Factory.create(:user)
  end

  test "should not work without login" do
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

  test "should get index" do
    get(:index, nil, {'user_id' => @user.id})
    assert_response :success
    assert_not_nil assigns(:experiences)
  end

  test "should create experience" do
    assert_difference('Experience.count') do
      post(:create, {:experience => @experience.attributes}, {'user_id' => @user.id})
    end
    assert_redirected_to experiences_path
  end

  test "should show experience" do
    get(:show, {:id => @experience}, {'user_id' => @user.id})
    assert_response :success
  end
  
  test "should get edit" do
    get(:edit, {:id => @experience}, {'user_id' => @user.id})
    assert_response :success
  end

  test "should update experience" do
    put(:update, {:id => @experience, :experience => @experience.attributes}, {'user_id' => @user.id})
    assert_redirected_to experiences_path
  end

  test "should destroy experience" do
    assert_difference('Experience.count', -1) do
      delete(:destroy, {:id => @experience}, {'user_id' => @user.id})
    end
    assert_redirected_to experiences_path
  end
end

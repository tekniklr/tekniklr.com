require 'test_helper'

class ExperiencesControllerTest < ActionController::TestCase
  fixtures  :experiences
  
  setup do
    @experience = experiences('one')
  end

  test "should not work without login" do
    get :index
    assert_redirected_to root_url

    post :create
    assert_redirected_to root_url

    put :update, id: @experience.id, experience: @experience.attributes
    assert_redirected_to root_url

    delete :destroy, id: @experience.to_param
    assert_redirected_to root_url
  end

  test "should get index" do
    get(:index, nil, {'user_id' => 1})
    assert_response :success
    assert_not_nil assigns(:experiences)
  end

  test "should create experience" do
    assert_difference('Experience.count') do
      post(:create, {:start_date => '2099-01-01', :title => 'Mega Woman', :affiliation => 'Futureplace', :location => 'Portland, OR'}, {'user_id' => 1})
    end
    assert_redirected_to experience_path
  end

  test "should update experience" do
    put(:update, {id: @experience.to_param, experience: @experience.attributes}, {'user_id' => 1})
    assert_redirected_to experience_path
  end

  test "should destroy experience" do
    assert_difference('Experience.count', -1) do
      delete(:destroy, {id: @experience.to_param}, {'user_id' => 1})
    end
    assert_redirected_to experiences_path
  end
end

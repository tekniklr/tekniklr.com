require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  
  setup do
    @link = Factory.create(:link)
    @user = Factory.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url

    post :update_all
    assert_redirected_to root_url

    post :create, :link => @link.attributes
    assert_redirected_to root_url

    delete :destroy, :id => @link.to_param
    assert_redirected_to root_url
  end

  should "get index" do
    get(:index, nil, {'user_id' => @user.id})
    assert_response :success
    assert_not_nil assigns(:links)
  end

  should "create link" do
    assert_difference('Link.count') do
      post(:create, {:link => @link.attributes}, {'user_id' => @user.id})
    end
    assert_redirected_to links_path
  end

  should "update links" do
    @link2 = Factory.create(:link)
    put(:update_all, {:links => {@link.to_param => @link.attributes, @link2.to_param => @link2.attributes}}, {'user_id' => @user.id})
    assert_redirected_to links_path
  end

  should "destroy link" do
    assert_difference('Link.count', -1) do
      delete(:destroy, {:id => @link.to_param}, {'user_id' => @user.id})
    end
    assert_redirected_to links_path
  end
end

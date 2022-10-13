require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  
  setup do
    @link = FactoryBot.create(:link)
    @user = FactoryBot.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url

    post :update_all
    assert_redirected_to root_url

    post :create, params: {link: FactoryBot.attributes_for(:link)}
    assert_redirected_to root_url

    delete :destroy, params: {id: @link.to_param}
    assert_redirected_to root_url
  end

  should "get index" do
    get :index, params: {}, session: {user_id: @user.id}
    assert_response :success
    assert_not_nil assigns(:links)
  end

  should "create link" do
    assert_difference('Link.count') do
      post :create, params: {link: FactoryBot.attributes_for(:link)}, session: {user_id: @user.id}
    end
    assert_redirected_to links_path
  end

  should "update links" do
    @link2 = FactoryBot.create(:link)
    put :update_all, params: {links: {@link.to_param => @link.attributes, @link2.to_param => @link2.attributes}}, session: {user_id: @user.id}
    assert_redirected_to links_path
  end

  should "destroy link" do
    assert_difference('Link.count', -1) do
      delete :destroy, params: {id: @link.to_param}, session: {user_id: @user.id}
    end
    assert_redirected_to links_path
  end
end

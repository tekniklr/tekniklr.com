require 'test_helper'

class FavoritesControllerTest < ActionController::TestCase
  setup do
    @favorite = FactoryGirl.create(:favorite)
    @favorite2 = FactoryGirl.create(:favorite)
    @favorite_thing1 = FactoryGirl.create(:favorite_thing)
    @favorite_thing1.favorite = @favorite
    @favorite_thing2 = FactoryGirl.create(:favorite_thing)
    @favorite_thing2.favorite = @favorite
    @user = FactoryGirl.create(:user)
  end

  should "not work without login" do
    get :index
    assert_redirected_to root_url
    
    get :new
    assert_redirected_to root_url
    
    post :create, :favorite => @favorite.attributes
    assert_redirected_to root_url
    
    get :show, :id => @favorite.to_param
    assert_redirected_to root_url
    
    get :edit, :id => @favorite.to_param
    assert_redirected_to root_url

    put :sort_favorites, :favorite => @favorite.to_param
    assert_redirected_to root_url

    put :sort_things, :favorite_thing => @favorite_thing1.to_param
    assert_redirected_to root_url
    
    put :update, :id => @favorite.to_param, :favorite => @favorite.attributes
    assert_redirected_to root_url
    
    delete :destroy, :id => @favorite.to_param
    assert_redirected_to root_url
  end

  should "get index" do
    get(:index, nil, {'user_id' => @user.id})
    assert_response :success
    assert_not_nil assigns(:favorites)
  end

  should "get new" do
    get(:new, nil, {'user_id' => @user.id})
    assert_response :success
  end

  should "create favorite" do
    assert_difference('Favorite.count') do
      post(:create, {:favorite => @favorite.attributes}, {'user_id' => @user.id})
    end
    assert_redirected_to favorite_path(assigns(:favorite))
  end

  should "show favorite" do
    get(:show, {:id => @favorite.id}, {'user_id' => @user.id})
    assert_response :success
  end

  should "get edit" do
    get(:edit, {:id => @favorite.to_param}, {'user_id' => @user.id})
    assert_response :success
  end

  should "re-order favorites" do
    put(:sort_favorites, {:favorite => [@favorite.to_param, @favorite2.to_param]}, {'user_id' => @user.id})
    assert_redirected_to favorites_path
  end

  should "re-order things" do
    put(:sort_things, {:favorite_thing => [@favorite_thing1.to_param, @favorite_thing2.to_param]}, {'user_id' => @user.id})
    assert_redirected_to favorites_path
  end

  should "update favorite" do
    put(:update, {:id => @favorite.to_param, :favorite => @favorite.attributes}, {'user_id' => @user.id})
    assert_redirected_to favorite_path(assigns(:favorite))
  end

  should "destroy favorite" do
    assert_difference('Favorite.count', -1) do
      delete(:destroy, {:id => @favorite.to_param}, {'user_id' => @user.id})
    end
    assert_redirected_to favorites_path
  end
end

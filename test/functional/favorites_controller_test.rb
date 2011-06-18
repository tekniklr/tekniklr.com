require 'test_helper'

class FavoritesControllerTest < ActionController::TestCase
  setup do
    @favorite = favorites(:movies)
    @favorite_thing1 = favorite_things(:google_movie)
    @favorite_thing1.favorite = @favorite
    @favorite_thing2 = favorite_things(:yahoo_movie)
    @favorite_thing2.favorite = @favorite
  end

  test "should not work without login" do
    get :index
    assert_redirected_to root_url
    
    get :new
    assert_redirected_to root_url
    
    post :create, favorite: @favorite.attributes
    assert_redirected_to root_url
    
    get :show, id: @favorite.to_param
    assert_redirected_to root_url
    
    get :edit, id: @favorite.to_param
    assert_redirected_to root_url

    put :sort, favorite_things: @favorite_thing1.attributes
    assert_redirected_to root_url
    
    put :update, id: @favorite.to_param, favorite: @favorite.attributes
    assert_redirected_to root_url
    
    delete :destroy, id: @favorite.to_param
    assert_redirected_to root_url
  end

  test "should get index" do
    get(:index, nil, {'user_id' => 1})
    assert_response :success
    assert_not_nil assigns(:favorites)
  end

  test "should get new" do
    get(:new, nil, {'user_id' => 1})
    assert_response :success
  end

  test "should create favorite" do
    assert_difference('Favorite.count') do
      post(:create, {favorite: @favorite.attributes}, {'user_id' => 1})
    end
    assert_redirected_to favorite_path(assigns(:favorite))
  end

  test "should show favorite" do
    get(:show, {id: @favorite.id}, {'user_id' => 1})
    assert_response :success
  end

  test "should get edit" do
    get(:edit, {id: @favorite.to_param}, {'user_id' => 1})
    assert_response :success
  end

  test "should re-order things" do
    put(:sort, {favorite_thing: [@favorite_thing1.to_param, @favorite_thing2.to_param]}, {'user_id' => 1})
    assert_redirected_to favorites_path
  end

  test "should update favorite" do
    put(:update, {id: @favorite.to_param, favorite: @favorite.attributes}, {'user_id' => 1})
    assert_redirected_to favorite_path(assigns(:favorite))
  end

  test "should destroy favorite" do
    assert_difference('Favorite.count', -1) do
      delete(:destroy, {id: @favorite.to_param}, {'user_id' => 1})
    end
    assert_redirected_to favorites_path
  end
end

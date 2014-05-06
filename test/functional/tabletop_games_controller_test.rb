require 'test_helper'

class TabletopGamesControllerTest < ActionController::TestCase
  setup do
    @tabletop_game = FactoryGirl.create(:tabletop_game)
    @user = FactoryGirl.create(:user)
  end

  should "only allow limited access without login" do
    get :index
    assert_response :success

    get :manage
    assert_redirected_to root_url
    
    get :new
    assert_redirected_to root_url
    
    post :create, :tabletop_game => @tabletop_game.attributes
    assert_redirected_to root_url
    
    get :edit, :id => @tabletop_game.to_param
    assert_redirected_to root_url
    
    put :update, :id => @tabletop_game.to_param, :tabletop_game => @tabletop_game.attributes
    assert_redirected_to root_url
    
    delete :destroy, :id => @tabletop_game.to_param
    assert_redirected_to root_url
  end

  should "get index" do
    get(:index, nil, {'user_id' => @user.id})
    assert_response :success
    assert_not_nil assigns(:tabletop_games)
  end

  should "get admin index" do
    get(:manage, nil, {'user_id' => @user.id})
    assert_response :success
    assert_not_nil assigns(:tabletop_games)
  end

  should "get new" do
    get(:new, nil, {'user_id' => @user.id})
    assert_response :success
  end

  should "create tabletop_game" do
    assert_difference('TabletopGame.count') do
      post(:create, {:tabletop_game => @tabletop_game.attributes}, {'user_id' => @user.id})
    end
    assert_redirected_to manage_tabletop_games_path
  end

  should "get edit" do
    get(:edit, {:id => @tabletop_game.to_param}, {'user_id' => @user.id})
    assert_response :success
  end

  should "update tabletop_game" do
    put(:update, {:id => @tabletop_game.to_param, :tabletop_game => @tabletop_game.attributes}, {'user_id' => @user.id})
    assert_redirected_to manage_tabletop_games_path
  end

  should "destroy tabletop_game" do
    assert_difference('TabletopGame.count', -1) do
      delete(:destroy, {:id => @tabletop_game.to_param}, {'user_id' => @user.id})
    end
    assert_redirected_to manage_tabletop_games_path
  end
end

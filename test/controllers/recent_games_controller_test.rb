require 'test_helper'

class RecentGamesControllerTest < ActionController::TestCase
  setup do
    @recent_game = FactoryGirl.create(:recent_game)
    @user = FactoryGirl.create(:user)
  end

  should "only allow limited access without login" do
    get :new
    assert_redirected_to root_url
    
    post :create, params: {recent_game: @recent_game.attributes}
    assert_redirected_to root_url
    
    get :edit, params: {id: @recent_game}
    assert_redirected_to root_url
    
    put :update, params: {id: @recent_game, recent_game: @recent_game.attributes}
    assert_redirected_to root_url

    delete :destroy, params: {id: @recent_game.to_param}
    assert_redirected_to root_url
  end

  should "get new" do
    get :new, params: {}, session: {user_id: @user.id}
    assert_response :success
  end

  should "create recent_game" do
    assert_difference('RecentGame.count') do
      post :create, params: {recent_game: @recent_game.attributes}, session: {user_id: @user.id}
    end
    assert_redirected_to new_recent_game_path
  end

  should "get edit" do
    get :edit, params: {id: @recent_game}, session: {user_id: @user.id}
    assert_response :success
  end

  should "update recent_game" do
    put :update, params: {id: @recent_game, recent_game: @recent_game.attributes}, session: {user_id: @user.id}
    assert_redirected_to new_recent_game_path
  end

  should "destroy recent_game" do
    assert_difference('RecentGame.count', -1) do
      delete :destroy, params: {id: @recent_game.to_param}, session: {user_id: @user.id}
    end
    assert_redirected_to new_recent_game_path
  end
end

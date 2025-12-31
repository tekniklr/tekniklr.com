require 'test_helper'

class GotyControllerTest < ActionController::TestCase
  setup do
    @goty = FactoryBot.create(:goty, year: 2025, published: true)
    @gg1 = FactoryBot.create(:goty_game, goty: @goty)
    @gg2 = FactoryBot.create(:goty_game, goty: @goty)
    @unpublished_goty = FactoryBot.create(:goty, year: 2026, published: false)
    @user = FactoryBot.create(:user)
  end

  should "only allow limited access without login" do
    get :show, params: {year: '2025'}
    assert_response :success

    get :show, params: {year: '2026'}
    assert_response :not_found

    get :edit
    assert_redirected_to root_url

    put :sort
    assert_redirected_to root_url

    put :update_explanation, params: {goty_game_id: @goty.goty_games.first.id, explanation: 'Some terrible reasoning.'}
    assert_redirected_to root_url
  end

  should "get show for published goty when not logged in" do
    get :show, params: {year: '2025'}
    assert_response :success
  end

  should "get show for unpublished goty when logged in" do
    get :show, params: {year: '2026'}, session: {user_id: @user.id}
    assert_response :success
  end

  should "get edit" do
    get :edit, session: {user_id: @user.id}
    assert_response :success
  end

  should "re-order" do
    put :sort, params: {game_ids: [@gg1.id, @gg2.id]}, session: {user_id: @user.id}
    assert_response :success
  end

  should "update goty_game explanation" do
    put :update_explanation, params: {goty_game_id: @gg1.id, goty_game: {explanation: 'Some terrible reasoning.'}}, session: {user_id: @user.id}
    assert_response :success
  end

  should "update goty published status" do
    assert !@unpublished_goty.published?
    put :update_published, params: {goty_id: @unpublished_goty.id}, session: {user_id: @user.id}
    assert_response :success
    @unpublished_goty.reload
    assert @unpublished_goty.published?
  end

end

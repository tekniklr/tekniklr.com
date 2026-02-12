require 'test_helper'

class TabletopGameTest < ActiveSupport::TestCase

  def setup
    @tabletop_game = FactoryBot.create(:tabletop_game)
  end

  context "when validating" do

    should "be valid as stubbed" do
      assert @tabletop_game.valid?
    end

    should "validate presence of name" do
      @tabletop_game.name = nil
      assert !@tabletop_game.valid?
    end

  end

  context "when looking at player counts" do

    setup do
      @t1 = FactoryBot.create(:tabletop_game, players: '2')
      @t2 = FactoryBot.create(:tabletop_game, players: '2-6')
      @t3 = FactoryBot.create(:tabletop_game, players: '7+')
      @t4 = FactoryBot.create(:tabletop_game, players: 'something weird')
      @t5 = FactoryBot.create(:tabletop_game, players: nil)
    end

    should "know min players if available" do
      assert_equal '2',   @t1.players_min
      assert_equal '2',   @t2.players_min
      assert_equal '7',   @t3.players_min
      assert_nil   @t4.players_min
      assert_nil   @t5.players_min
    end

    should "know max players if available" do
      assert_equal '2',   @t1.players_max
      assert_equal '6',   @t2.players_max
      assert_nil   @t3.players_max
      assert_nil   @t4.players_max
      assert_nil   @t5.players_max
    end

  end

end

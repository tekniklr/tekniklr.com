require 'test_helper'

class GotyGameTest < ActiveSupport::TestCase

  should belong_to :goty
  should belong_to :game

  context "when validating" do

    setup do
      @goty_game = FactoryBot.build(:goty_game)
    end

    should "be valid as stubbed" do
      assert @goty_game.valid?, "should be valid as created by factory_bot #{@goty_game.errors.inspect}"
    end

    should "validate sort" do
      @goty_game.sort = nil
      assert !@goty_game.valid?
      @goty_game.sort = 'a'
      assert !@goty_game.valid?
      @goty_game.sort = 0
      assert @goty_game.valid?
    end
    
  end

end

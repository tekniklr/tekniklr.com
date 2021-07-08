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

end

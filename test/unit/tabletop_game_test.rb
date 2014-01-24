require 'test_helper'

class TabletopGameTest < ActiveSupport::TestCase

  def setup
    @tabletop_game = Factory.create(:tabletop_game)
  end

  should "validate presence of name" do
    @tabletop_game.name = nil
    assert_equal(false, @tabletop_game.save)
  end

end

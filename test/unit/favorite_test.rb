require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase

  def setup
    @favorite = Factory.create(:favorite)
  end

  should "validate presence of type" do
    @favorite.favorite_type = nil
    assert_equal(false, @favorite.save)
  end
  
  should "validate size of type" do
    @favorite.favorite_type = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @favorite.save)
  end
  
  should "validate presence of sort" do
    @favorite.sort = nil
    assert_equal(false, @favorite.save)
  end

  should "validate type of sort" do
    @favorite.sort = 'a'
    assert_equal(false, @favorite.save)
  end
  
end

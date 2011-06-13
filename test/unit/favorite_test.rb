require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  fixtures :favorites

  def setup
    @favorite = Favorite.new
    @favorite.favorite_type = 'Movies'
    @favorite.order = 1
  end

  def test_validates_presence_of_type
    @favorite.favorite_type = nil
    assert_equal(false, @favorite.save)
  end
  
  def test_validates_size_of_type
    @favorite.favorite_type = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @favorite.save)
  end
  
  def test_validates_presence_of_order
    @favorite.order = nil
    assert_equal(false, @favorite.save)
  end

  def test_validates_type_of_order
    @favorite.order = 'a'
    assert_equal(false, @favorite.save)
  end
  
end

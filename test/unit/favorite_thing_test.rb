require 'test_helper'

class FavoriteThingTest < ActiveSupport::TestCase
  fixtures :favorite_things

  def setup
    @favorite_thing = FavoriteThing.new
    @favorite_thing.favorite_id = 1
    @favorite_thing.thing = 'The google movie'
    @favorite_thing.link = 'http://google.com'
    @favorite_thing.order = 1
  end
  
  def test_validates_presence_of_thing
    @favorite_thing.thing = nil
    assert_equal(false, @favorite_thing.save)
  end
  
  def test_validates_cromulence_of_link
    @favorite_thing.link = 'google.com'
    assert_equal(false, @favorite_thing.save)
  end
  
  def test_validates_size_of_link
    @favorite_thing.link = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvyb'
    assert_equal(false, @favorite_thing.save)
  end
  
  def test_submit_without_link
    @favorite_thing.link = nil
    assert_equal(true, @favorite_thing.save)
  end
  
  def test_validates_presence_of_thing
    @favorite_thing.thing = nil
    assert_equal(false, @favorite_thing.save)
  end
  
  def test_validates_size_of_thing
    @favorite_thing.thing = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @favorite_thing.save)
  end
  
  def test_validates_presence_of_order
    @favorite_thing.order = nil
    assert_equal(false, @favorite_thing.save)
  end
  
  def test_validates_type_of_order
    @favorite_thing.order = 'a'
    assert_equal(false, @favorite_thing.save)
  end
  
end

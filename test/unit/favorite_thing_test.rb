require 'test_helper'

class FavoriteThingTest < ActiveSupport::TestCase

  def setup
    @favorite_thing = Factory.build(:favorite_thing)
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
    @favorite_thing.link = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvybqwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvyb'
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
  
  def test_validates_presence_of_sort
    @favorite_thing.sort = nil
    assert_equal(false, @favorite_thing.save)
  end
  
  def test_validates_type_of_sort
    @favorite_thing.sort = 'a'
    assert_equal(false, @favorite_thing.save)
  end
  
end

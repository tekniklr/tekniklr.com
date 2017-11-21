require 'test_helper'

class FavoriteThingTest < ActiveSupport::TestCase

  def setup
    @favorite_thing = FactoryBot.build(:favorite_thing)
  end
  
  should "validate cromulence of link" do
    @favorite_thing.link = 'google.com'
    assert_equal(false, @favorite_thing.save)
  end
  
  should "validate size of link" do
    @favorite_thing.link = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvybqwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvyb'
    assert_equal(false, @favorite_thing.save)
  end
  
  should "submit without link" do
    @favorite_thing.link = nil
    assert_equal(true, @favorite_thing.save)
  end
  
  should "validate presence of thing" do
    @favorite_thing.thing = nil
    assert_equal(false, @favorite_thing.save)
  end
  
  should "validate size of thing" do
    @favorite_thing.thing = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @favorite_thing.save)
  end
  
  should "validate presence of sort" do
    @favorite_thing.sort = nil
    assert_equal(false, @favorite_thing.save)
  end
  
  should "validate type of sort" do
    @favorite_thing.sort = 'a'
    assert_equal(false, @favorite_thing.save)
  end
  
end

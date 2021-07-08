require 'test_helper'

class FavoriteThingTest < ActiveSupport::TestCase

  def setup
    @favorite_thing = FactoryBot.build(:favorite_thing)
  end

  context "when validating" do

    should "be valid as stubbed" do
      assert @favorite_thing.valid?
    end
  
    should "validate cromulence of link" do
      @favorite_thing.link = 'google.com'
      assert !@favorite_thing.valid?
    end
    
    should "validate size of link" do
      @favorite_thing.link = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvybqwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvyb'
      assert !@favorite_thing.valid?
    end
    
    should "submit without link" do
      @favorite_thing.link = nil
      assert @favorite_thing.valid?
    end
    
    should "validate presence of thing" do
      @favorite_thing.thing = nil
      assert !@favorite_thing.valid?
    end
    
    should "validate size of thing" do
      @favorite_thing.thing = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      assert !@favorite_thing.valid?
    end
    
    should "validate presence of sort" do
      @favorite_thing.sort = nil
      assert !@favorite_thing.valid?
    end
    
    should "validate type of sort" do
      @favorite_thing.sort = 'a'
      assert !@favorite_thing.valid?
    end

  end
  
end

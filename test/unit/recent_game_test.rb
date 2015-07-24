require 'test_helper'

class RecentGameTest < ActiveSupport::TestCase

  def setup
    @game = FactoryGirl.build(:recent_game)
  end

  should "validate presence of name" do
    @game.name = nil
    assert_equal(false, @game.save)
  end
  
  should "validate size of name" do
    @game.name = '0123456789012345678901234567890123456789001234567890123456789012345678901234567890'
    assert_equal(false, @game.save)
  end

  should "validate presence of platform" do
    @game.platform = nil
    assert_equal(false, @game.save)
  end
  
  should "validate size of platform" do
    @game.platform = '0123456789012'
    assert_equal(false, @game.save)
  end

  should "validate presence of started_playing" do
    @game.started_playing = nil
    assert_equal(false, @game.save)
  end
  
  should "validate type of started_playing" do
    @game.started_playing = '0123456789012'
    assert_equal(false, @game.save)
  end
  
  should "not validate presence of url" do
    @game.url = nil
    assert_equal(true, @game.save)
  end
  
  should "validate size of url" do
    @game.url = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyfghjnctfvgbjnkmcfvgjnkmcdtfvgjnkmtfvgybhjnkmftcgvbhjnkvygbhjnkmu.com'
    assert_equal(false, @game.save)
  end
  
  should "validate cromulence of url" do
    @game.url = 'google.com'
    assert_equal(false, @game.save)
  end
  
end

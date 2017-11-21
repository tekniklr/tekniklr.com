require 'test_helper'

class ExperienceTest < ActiveSupport::TestCase

  def setup
    @experience = FactoryBot.build(:experience)
  end

  should "validate presence of title" do
    @experience.title = nil
    assert_equal(false, @experience.save)
  end
  
  should "validate size of title" do
    @experience.title = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @experience.save)
  end
  
  should "validate presence of affiliation" do
    @experience.affiliation = nil
    assert_equal(false, @experience.save)
  end
 
  should "validate size of affiliation" do
    @experience.affiliation = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @experience.save)
  end
  
  should "validate size of location" do
    @experience.location = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @experience.save)
  end
  
  should "submit without location" do
    @experience.location = nil
    assert_equal(true, @experience.save)
  end
  
  should "submit without affiliation link" do
    @experience.affiliation_link = nil
    assert_equal(true, @experience.save)
  end
  
  should "validate size of affiliation link" do
    @experience.affiliation_link = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvybqwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvyb'
    assert_equal(false, @experience.save)
  end
  
  should "validate cromulence of affiliation link" do
    @experience.affiliation_link = 'google.com'
    assert_equal(false, @experience.save)
  end
  
  should "validate presence of start date" do
    @experience.start_date = nil
    assert_equal(false, @experience.save)
  end
  
  should "validate type of start date" do
    @experience.start_date = 'a'
    assert_equal(false, @experience.save)
  end
  
  should "submit without end date" do
    @experience.end_date = nil
    assert_equal(true, @experience.save)
  end
  
end

require 'test_helper'

class LinkTest < ActiveSupport::TestCase

  def setup
    @link = FactoryGirl.build(:link)
  end

  should "validate presence of name" do
    @link.name = nil
    assert_equal(false, @link.save)
  end
  
  should "validate size of name" do
    @link.name = '01234567890123456789012345678901234567890'
    assert_equal(false, @link.save)
  end
  
  should "validate presence of url" do
    @link.url = nil
    assert_equal(false, @link.save)
  end
  
  should "validate size of url" do
    @link.url = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyfghjnctfvgbjnkmcfvgjnkmcdtfvgjnkmtfvgybhjnkmftcgvbhjnkvygbhjnkmu.com'
    assert_equal(false, @link.save)
  end
  
  should "validate cromulence of url" do
    @link.url = 'google.com'
    assert_equal(false, @link.save)
  end

  should "visible links should not show all" do
    visible = Link.get_visible
    whuffie = visible.find_by_name('Whuffie Bank')
    assert_equal(whuffie, nil)
  end
  
end

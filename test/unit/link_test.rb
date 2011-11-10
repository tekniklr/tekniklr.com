require 'test_helper'

class LinkTest < ActiveSupport::TestCase

  def setup
    @link = Factory.build(:link)
  end

  def test_validates_presence_of_name
    @link.name = nil
    assert_equal(false, @link.save)
  end
  
  def test_validates_size_of_name
    @link.name = '01234567890123456789012345678901234567890'
    assert_equal(false, @link.save)
  end
  
  def test_validates_presence_of_url
    @link.url = nil
    assert_equal(false, @link.save)
  end
  
  def test_validates_size_of_url
    @link.url = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyfghjnctfvgbjnkmcfvgjnkmcdtfvgjnkmtfvgybhjnkmftcgvbhjnkvygbhjnkmu.com'
    assert_equal(false, @link.save)
  end
  
  def test_validates_cromulence_of_url
    @link.url = 'google.com'
    assert_equal(false, @link.save)
  end

  def test_visible_links_should_not_show_all
    visible = Link.get_visible
    whuffie = visible.find_by_name('Whuffie Bank')
    assert_equal(whuffie, nil)
  end
  
end

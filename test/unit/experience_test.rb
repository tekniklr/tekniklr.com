require 'test_helper'

class ExperienceTest < ActiveSupport::TestCase
  fixtures :experiences

  def setup
    @experience = Experience.new
    @experience.title = 'Corrections officer'
    @experience.affiliation = 'Hall of Records'
    @experience.start_date = '2001-01-31'.to_date
  end

  def test_validates_presence_of_title
    @experience.title = nil
    assert_equal(false, @experience.save)
  end
  
  def test_validates_size_of_title
    @experience.title = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @experience.save)
  end
  
  def test_validates_presence_of_affiliation
    @experience.affiliation = nil
    assert_equal(false, @experience.save)
  end
 
  def test_validates_size_of_affiliation
    @experience.affiliation = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @experience.save)
  end
  
  def test_validates_size_of_location
    @experience.location = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @experience.save)
  end
  
  def test_submit_without_location
    @experience.location = nil
    assert_equal(true, @experience.save)
  end
  
  def test_validates_presence_of_start_date
    @experience.start_date = nil
    assert_equal(false, @experience.save)
  end
  
  def test_validates_type_of_start_date
    @experience.start_date = 'a'
    assert_equal(false, @experience.save)
  end
  
  def test_submit_without_end_date
    @experience.end_date = nil
    assert_equal(true, @experience.save)
  end
  
end

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
  
  def test_validates_presence_of_affiliation
    @experience.affiliation = nil
    assert_equal(false, @experience.save)
  end
  
  def test_validates_presence_of_start_date
    @experience.start_date = nil
    assert_equal(false, @experience.save)
  end
  
end

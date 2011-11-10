require 'test_helper'

class FacetTest < ActiveSupport::TestCase
  
  def setup
    @facet = Factory.build(:facet)
  end

  def test_validates_presence_of_name
    @facet.name = nil
    assert_equal(false, @facet.save)
  end
  
  def test_validates_size_of_name
    @facet.name = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @facet.save)
  end
  
  def test_validates_presence_of_slug
    @facet.slug = nil
    assert_equal(false, @facet.save)
  end
  
  def test_validates_size_of_slug
    @facet.slug = '012345678901234567890'
    assert_equal(false, @facet.save)
  end
end

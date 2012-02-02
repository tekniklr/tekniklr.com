require 'test_helper'

class FacetTest < ActiveSupport::TestCase
  
  def setup
    @facet = Factory.build(:facet)
  end

  should "validate presence of name" do
    @facet.name = nil
    assert_equal(false, @facet.save)
  end
  
  should "validate size of name" do
    @facet.name = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    assert_equal(false, @facet.save)
  end
  
  should "validate presence of slug" do
    @facet.slug = nil
    assert_equal(false, @facet.save)
  end
  
  should "validate size of slug" do
    @facet.slug = '012345678901234567890'
    assert_equal(false, @facet.save)
  end
end

require 'test_helper'

class FacetTest < ActiveSupport::TestCase
  
  def setup
    @facet = FactoryBot.build(:facet)
  end

  context "when validating" do

    should "be valid as stubbed" do
      assert @facet.valid?
    end

    should "validate presence of name" do
      @facet.name = nil
      assert !@facet.valid?
    end
    
    should "validate size of name" do
      @facet.name = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      assert !@facet.valid?
    end
    
    should "validate presence of slug" do
      @facet.slug = nil
      assert !@facet.valid?
    end
    
    should "validate size of slug" do
      @facet.slug = '012345678901234567890'
      assert !@facet.valid?
    end

    should "not be valid if a facet with its slug already exists" do
      @facet1 = FactoryBot.create(:facet, slug: 'facet_uniq')
      assert @facet1.valid?
      @facet2 = FactoryBot.build(:facet, slug: 'facet_uniq')
      assert !@facet2.valid?
    end

  end

  should "use the value when outputing facet as a string" do
    @facet.value = "shemp!"
    assert_equal "shemp!", @facet.to_s
  end

end

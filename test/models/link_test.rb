require 'test_helper'

class LinkTest < ActiveSupport::TestCase

  def setup
    @link = FactoryBot.build(:link)
  end

  context "when validating" do

    should "be valid as stubbed" do
      assert @link.valid?
    end

    should "validate presence of name" do
      @link.name = nil
      assert !@link.valid?
    end
    
    should "validate size of name" do
      @link.name = '01234567890123456789012345678901234567890'
      assert !@link.valid?
    end
    
    should "validate presence of url" do
      @link.url = nil
      assert !@link.valid?
    end
    
    should "validate size of url" do
      @link.url = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyfghjnctfvgbjnkmcfvgjnkmcdtfvgjnkmtfvgybhjnkmftcgvbhjnkvygbhjnkmu.com'
      assert !@link.valid?
    end
    
    should "validate cromulence of url" do
      @link.url = 'google.com'
      assert !@link.valid?
    end

  end

  should "visible links should not show all" do
    visible = Link.get_visible
    whuffie = visible.find_by_name('Whuffie Bank')
    assert_nil whuffie
  end
  
end

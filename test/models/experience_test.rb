require 'test_helper'

class ExperienceTest < ActiveSupport::TestCase

  def setup
    @experience = FactoryBot.build(:experience)
  end

  context "when validating" do

    should "be valid as stubbed" do
      assert @experience.valid?
    end

    should "validate presence of title" do
      @experience.title = nil
      assert !@experience.valid?
    end
    
    should "validate size of title" do
      @experience.title = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      assert !@experience.valid?
    end
    
    should "validate presence of affiliation" do
      @experience.affiliation = nil
      assert !@experience.valid?
    end
   
    should "validate size of affiliation" do
      @experience.affiliation = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      assert !@experience.valid?
    end
    
    should "validate size of location" do
      @experience.location = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      assert !@experience.valid?
    end
    
    should "submit without location" do
      @experience.location = nil
      assert @experience.valid?
    end
    
    should "submit without affiliation link" do
      @experience.affiliation_link = nil
      assert @experience.valid?
    end
    
    should "validate size of affiliation link" do
      @experience.affiliation_link = 'http://qwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvybqwertyuiopasdfghjklzxcvbnmqwertyuiopasdfghjklzxcvbnmqwertyu.com/eryctuvyibunctvyibuictvybuhnictvybunimodctbhjnctfgvybhnjctvyb'
      assert !@experience.valid?
    end
    
    should "validate cromulence of affiliation link" do
      @experience.affiliation_link = 'google.com'
      assert !@experience.valid?
    end
    
    should "validate presence of start date" do
      @experience.start_date = nil
      assert !@experience.valid?
    end
    
    should "validate type of start date" do
      @experience.start_date = 'a'
      assert !@experience.valid?
    end
    
    should "submit without end date" do
      @experience.end_date = nil
      assert @experience.valid?
    end

  end
  
end

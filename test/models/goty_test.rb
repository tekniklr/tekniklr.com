require 'test_helper'

class GotyTest < ActiveSupport::TestCase

  should have_many :goty_games

  context "when validating" do

    setup do
      @goty = FactoryBot.build(:goty)
    end

    should "be valid as stubbed" do
      assert @goty.valid?
    end

    should "validate year" do
      @goty.year = nil
      assert !@goty.valid?
      @goty.year = 'not a year'
      assert !@goty.valid?
      @goty.year = 12345
      assert !@goty.valid?
      @goty.year = 2025
      assert @goty.valid?
    end

    should "validate uniqueness of year" do
      @goty.year = 2025
      assert @goty.valid?
      @goty.save
      goty2 = FactoryBot.build(:goty, year: 2025)
      assert !goty2.valid?
    end
    
  end

  should "provide a formatted explanation" do
    goty = FactoryBot.build(:goty)
    assert_equal "click to add explanation", goty.formatted_explanation
    goty.explanation = "this is \n a test"
    assert_equal "<p>this is \n<br /> a test</p>", goty.formatted_explanation
  end

end

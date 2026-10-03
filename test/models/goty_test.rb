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

  should "know how long the list for this year should be" do
    goty = FactoryBot.build(:goty)
    2.times { goty.goty_games.build }
    assert_equal 2, goty.top_num, 'should show complete number when under 3'
    2.times { goty.goty_games.build }
    assert_equal 3, goty.top_num, 'should show 3 when under 5'
    4.times { goty.goty_games.build }
    assert_equal 5, goty.top_num, 'should show 5 when under 10'
    5.times { goty.goty_games.build }
    assert_equal 10, goty.top_num, 'should show 10 when over 10'
  end

end

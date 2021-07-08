require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase

  def setup
    @favorite = FactoryBot.create(:favorite)
  end

  context "when validating" do

    should "be valid as stubbed" do
      assert @favorite.valid?
    end

    should "validate presence of type" do
      @favorite.favorite_type = nil
      assert !@favorite.valid?
    end
    
    should "validate size of type" do
      @favorite.favorite_type = '012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      assert !@favorite.valid?
    end
    
    should "validate presence of sort" do
      @favorite.sort = nil
      assert !@favorite.valid?
    end

    should "validate type of sort" do
      @favorite.sort = 'a'
      assert !@favorite.valid?
    end
    
  end

end

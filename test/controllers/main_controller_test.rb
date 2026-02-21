require 'test_helper'

class MainControllerTest < ActionController::TestCase
  
  should "get index" do
    expiries = []
    CACHED_ITEMS.each do |cache|
      expiries << cache[1]
    end

    expiries.each do |expiry|
      Rails.cache.delete(expiry)
    end

    assert_enqueued_jobs 7 do
      get :index
    end
    assert_response :success

    expiries.each do |expiry|
      cached_expiry = Rails.cache.read(expiry)
      assert (cached_expiry > Time.now), "#{expiry} should be in the future but was #{cached_expiry}"
    end

    assert_performed_jobs 0
    clear_enqueued_jobs
  end
  
  should "get colophon" do
    get :colophon
    assert_response :success
  end
  
end

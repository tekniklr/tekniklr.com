ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_bot_rails'
require 'shoulda-matchers'
require 'minitest/pride'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
require 'shoulda-context'

class ActiveSupport::TestCase
end

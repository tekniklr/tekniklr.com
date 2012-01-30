source 'http://rubygems.org'

gem 'rails', '3.2.1'
gem 'mysql2'

# better html
gem 'haml'

# javascript funtimes
gem 'jquery-rails'

# needed for authentication
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'json'

gem 'validates_timeliness'

gem 'feedzirra'

gem 'paperclip'

# Deploy with Capistrano
gem 'capistrano'

group :assets do
  gem 'sprockets'
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '~> 1.0.3'
end

group :test do
  gem 'turn', :require => false
  gem 'factory_girl_rails', :require => false
  gem 'minitest', :require => false
end

group :production do
  gem 'exception_notification'
  gem 'therubyracer'  # dreamhost doesn't provide a js  runtime but OSX does
end

# prevent console errors
group :development do
  gem "wirble", :require => false
  gem "hirb", :require => false
  gem "awesome_print", :require => false
  gem "looksee", :require => false
  # gem 'ruby-debug19', :require => 'ruby-debug'
end
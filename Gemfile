source 'http://rubygems.org'

gem 'rails', '3.2.6'
gem 'mysql2'

gem 'paperclip', '~> 2.7.0'
gem 'validates_timeliness'

# better html
gem 'haml'

# javascript funtimes
gem 'jquery-rails'

# needed for authentication
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'json'

# rss fetcher/parser that actually works
gem 'feedzirra'

# for amazon web services; not to be confused with ruby-aws
gem 'ruby-aaws'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

# Deploy with Capistrano
gem 'capistrano'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '~> 1.0.4'
end

group :test do
  gem 'turn', :require => false
  gem 'factory_girl', '<3.0.0', :require => false
  gem 'factory_girl_rails', '<3.0.0', :require => false
  gem 'minitest', :require => false
  gem 'shoulda', :require => false
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

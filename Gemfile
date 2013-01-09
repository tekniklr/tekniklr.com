source 'http://rubygems.org'

gem 'rails', '3.2.11'
gem 'mysql2'

gem 'paperclip', '~> 2.7.0' # requires ruby 1.9.2 to go higher
gem 'validates_timeliness'

gem 'system_timer'

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
gem 'rvm-capistrano'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test do
  gem 'turn', :require => false
  gem 'factory_girl', '<3.0.0', :require => false # requires ruby 1.9.2 to go higher
  gem 'factory_girl_rails', '<3.0.0', :require => false # requires ruby 1.9.2 to go higher
  gem 'minitest', :require => false
  gem 'shoulda', :require => false
end

group :production do
  gem 'exception_notification'
  gem 'libv8' # therubyracer needs this and it wasn't installling in the proper order
  gem 'therubyracer', '0.10.2', :platforms => :ruby  # dreamhost doesn't provide a js  runtime but OSX does
end

# prevent console errors
group :development do
  gem "wirble", :require => false
  gem "hirb", :require => false
  gem "awesome_print", :require => false
  gem "looksee", :require => false
  # gem 'ruby-debug19', :require => 'ruby-debug'
end

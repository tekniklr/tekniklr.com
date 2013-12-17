source 'http://rubygems.org'

gem 'rails', '3.2.16'
gem 'mysql2'

gem 'paperclip', '~> 2.7.0' # requires ruby 1.9.2 to go higher
gem 'validates_timeliness'

gem 'system_timer'

# better html
gem 'haml'

# javascript funtimes
gem 'jquery-rails'
gem 'jquery-ui-rails'

# needed for authentication
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'json'

# rss fetcher/parser that actually works
gem 'feedzirra'

# for amazon web services; not to be confused with ruby-aws
gem 'ruby-aaws'

gem 'htmlentities'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

# Deploy with Capistrano
gem 'capistrano', '<2.14.0'
gem 'rvm-capistrano'

# gems that shouldn't need to be specified, but since dreamhost is fucking 
# bollocks and stuck on ruby 1.9, we have to request an old version
gem 'nokogiri', '~> 1.4.4'

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
  gem 'shoulda', '3.4.0', :require => false  # requires ruby 1.9.2 to go higher
  gem 'shoulda-context', '1.1.0', :require => false  # get rid of this after upgrading shoulda
  gem 'shoulda-matchers', '1.5.6', :require => false  # get rid of this after upgrading shoulda
end

group :production do
  gem 'exception_notification', '~>3.0.1' # wasn't installing on dreamhost
  gem 'libv8' # therubyracer needs this and it wasn't installling in the proper order
  gem 'therubyracer', '0.10.2', :platforms => :ruby  # dreamhost doesn't provide a js  runtime but OSX does
end

# prevent console errors
group :development do
  gem "awesome_print"
  gem "pry-rails"
end

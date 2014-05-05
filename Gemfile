source 'http://rubygems.org'

gem 'rails', '3.2.17'
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
gem 'feedzirra', '<0.8' # higher versions come with a name switch and a nokogiri dependency that needs a newer ruby

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
# bollocks and stuck on ruby 1.8, we have to request an old version
gem 'nokogiri', '~> 1.4.4'

group :assets do
  gem 'sass-rails'
  gem 'sass', '< 3.3' # going higher triggers a ruby 1.8.7 bug re: gc_sweep, get rid of this gem requirement (it is implied by sass-rails) when ruby gets upgraded
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
end

# prevent console errors
group :development do
  gem "awesome_print", :require => false
  gem "pry-rails", :require => false
end

source 'http://rubygems.org'
ruby "2.0.0"

gem 'rails', '3.2.18'
gem 'mysql2'

gem 'paperclip'
gem 'validates_timeliness'

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
gem 'feedjira'

gem 'iconv'

# for amazon web services; not to be confused with ruby-aws
gem 'ruby-aaws'

gem 'htmlentities'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

# Deploy with Capistrano
gem 'capistrano'

group :assets do
  gem 'sass-rails'
  gem 'sass', '< 3.3' # going higher triggers a sprockets bug, get rid of this gem requirement (it is implied by sass-rails) later ( https://github.com/nex3/sass/issues/1162 )
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test do
  gem 'turn', :require => false
  gem 'factory_girl', :require => false
  gem 'factory_girl_rails', :require => false
  gem 'minitest', :require => false
  gem 'shoulda', :require => false
end

group :production do
  gem 'exception_notification'
  gem 'therubyracer'
end

# prevent console errors
group :development do
  gem "awesome_print"
  gem "pry-rails"
end

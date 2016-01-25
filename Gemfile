source 'http://rubygems.org'

gem 'rails', '<5'
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

gem 'similar_text'

gem 'iconv'

# for amazon web services; not to be confused with ruby-aws
gem 'ruby-aaws', :git => 'https://github.com/tekniklr/ruby-aaws.git'

gem 'htmlentities'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

# assets
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

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
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
end

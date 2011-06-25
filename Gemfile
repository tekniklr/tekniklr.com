source 'http://rubygems.org'
gem 'rails', '3.1.0.rc1'
gem 'sprockets'
gem 'mysql2'
gem 'rake', '0.8.7' # fixes undefined method 'Task' bug

# Asset template engines
gem 'sass'          # css 
gem 'haml'          # html
gem 'coffee-script' # javacript

# javascript funtimes
gem 'jquery-rails'

# needed for authentication
gem 'omniauth'
gem 'json'

gem 'validates_timeliness'

# Deploy with Capistrano
gem 'capistrano'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

group :production do
  gem 'uglifier'      # javascript condenser
  gem 'exception_notification'
end

# if your’e using Bundler in your Rails app, AND use gems in your 
# ~/.irbrc file AND attempt to start the Rails console; you’ll get 
# errors/warnings on requiring them UNLESS you define them in your 
# Gemfile
# http://matthewhutchinson.net/2010/9/19/rails-3-bash-aliases-and-irbrc-configs/page/2
group :development do
  gem "wirble"
  gem "hirb"
  gem "awesome_print"
  gem "looksee"
  
  # gem 'ruby-debug19', :require => 'ruby-debug'
end
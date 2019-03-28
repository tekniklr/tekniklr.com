source 'http://rubygems.org'

gem 'rails', '5.2.3'
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
gem 'omniauth-google-oauth2'
gem 'json'

# rss fetcher/parser that actually works
gem 'feedjira'
gem 'iconv' # needed to parse some feeds

gem 'lastfm'

gem 'twitter'

gem 'htmlentities'

gem 'mastodon-api', require: 'mastodon'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

# assets
gem 'sass-rails'
gem 'uglifier'

group :test do
  gem 'turn', require: false
  gem 'factory_bot_rails', require: false
  gem 'minitest', require: false
  gem 'shoulda', require: false
  gem 'rails-controller-testing'
end

group :production do
  gem 'exception_notification'
  gem 'therubyracer'
end

# prevent console errors
group :development do
  gem "awesome_print", require: false
  gem "pry-rails", require: false
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem "brakeman", require: false
end

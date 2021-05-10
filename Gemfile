source 'https://rubygems.org'

gem 'rails', '~>6.1.0'
gem 'mysql2'

gem 'kt-paperclip'
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
gem 'omniauth-rails_csrf_protection'
gem 'json'

# rss fetcher/parser that actually works
gem 'feedjira'
gem 'iconv' # needed to parse some feeds

gem 'lastfm'

gem 'twitter'

gem 'htmlentities'

gem 'mastodon-api', require: 'mastodon', git: 'https://github.com/tootsuite/mastodon-api.git', ref: '60b0ed0'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

# assets
gem 'sassc-rails'
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
  gem 'mini_racer'
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

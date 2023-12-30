source 'https://rubygems.org'

gem 'rails', '~>7.1.0'
gem 'mysql2'
gem 'puma'

gem 'haml'
gem 'sassc-rails'
gem 'uglifier'
gem "sprockets-rails"
gem 'jquery-rails'

gem 'kt-paperclip'
gem 'validates_timeliness', '>=7.0.0.beta1'

# needed for authentication
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# rss fetcher/parser that actually works
gem 'feedjira'
gem 'iconv' # needed to parse some feeds

# non-RSS external services/APIs
gem 'lastfm'
gem 'mastodon-api', require: 'mastodon', git: 'https://github.com/mastodon/mastodon-api'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

# hopefully temporary kludges
gem 'base64', '0.1.1' # passenger was failing to start with: "You have already activated base64 0.1.1, but your Gemfile requires base64 0.2.0. Since base64 is a default gem, you can either remove your dependency on it or try updating to a newer version of bundler that supports base64 as a default gem. (Gem::LoadError)"; upgrading bundler didn't help so use the old base64 for now (2023/11/10)

group :test do
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
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem "brakeman", require: false
end

source 'https://rubygems.org'

gem 'rails', '~>8.0.0'
gem 'mysql2'
gem 'puma'

gem 'haml'
gem 'sassc-rails'
gem "sprockets-rails"
gem 'jquery-rails'

gem 'kt-paperclip'

# needed for authentication
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'rack'

# rss fetcher/parser that actually works
gem 'feedjira'
gem 'iconv' # needed to parse some feeds

# just scraping stuff
gem 'nokogiri'

# non-RSS external services/APIs
gem 'lastfm'
gem 'mastodon-api', require: 'mastodon', git: 'https://github.com/mastodon/mastodon-api'
gem 'tumblr_client', git: 'https://github.com/tumblr/tumblr_client.git'

# run processes in the background
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

group :test do
  gem 'factory_bot_rails',       require: false
  gem 'minitest',                require: false
  gem 'shoulda',                 require: false
  gem 'rails-controller-testing'
end

group :production do
  gem 'exception_notification'
  gem 'terser'
end

group :development do
  gem "awesome_print",      require: false
  gem "pry-rails",          require: false
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano3-puma',   require: false, github: "seuros/capistrano-puma"
  gem "brakeman",           require: false
end
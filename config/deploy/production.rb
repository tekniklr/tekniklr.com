set :application, 'tekniklr.com'  # Your app's location (domain or sub-domain name as setup in panel)
set :rails_env, 'production'

# version control config
set :repo_url,  "https://github.com/tekniklr/tekniklr.com.git"
set :deploy_to, "/home/tekniklr/rails.tekniklr.com"
set :branch, 'master'
set :tmp_dir, "/home/tekniklr/tmp"

# symlinks to create
set :linked_files, %w{config/database.yml config/secrets.yml config/initializers/omniauth.rb config/.amazonrc config/initializers/lastfm.rb config/initializers/twitter.rb}
set :linked_dirs, %w{public/wpblog public/images public/icons public/recent_games public/favorite_things}

server 'tekniklr.com', user: 'tekniklr', roles: [:web, :app]

set :rbenv_type, :user
set :rbenv_ruby, '2.4.2'

set :ssh_options, {
  :forward_agent => true
}
set :use_sudo, false

set :keep_releases, 7
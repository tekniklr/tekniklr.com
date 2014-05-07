set :application, 'tekniklr.com'  # Your app's location (domain or sub-domain name as setup in panel)
set :rails_env, 'production'

# version control config
set :scm, :git
set :repo_url,  "git@github.com:tekniklr/tekniklr.com.git"
set :deploy_to, "/home/tekniklr/rails.tekniklr.com"
set :branch, 'master'
set :tmp_dir, "/home/tekniklr/tmp"

# symlinks to create
set :linked_files, %w{config/database.yml config/initializers/omniauth.rb config/initializers/secret_token.rb config/.amazonrc}
set :linked_dirs, %w{public/wpblog public/images system}

server 'tekniklr.com', user: 'tekniklr', roles: [:web, :app]

set :rvm_type, :user
set :rvm_ruby_version, '2.0.0-p451'

set :ssh_options, {
  :forward_agent => true
}
set :use_sudo, false

set :keep_releases, 7
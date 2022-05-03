set :rails_env, 'production'
server 'tekniklr.com', user: 'tekniklr', roles: [:web, :app]
set :deploy_to, "/home/tekniklr/rails.tekniklr.com"
set :branch, 'main'
set :tmp_dir, "/home/tekniklr/tmp"
set :rbenv_type, :user
set :rbenv_ruby, '3.1.2'
set :ssh_options, {
  forward_agent: true
}
set :use_sudo, false
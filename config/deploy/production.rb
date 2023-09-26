set :rails_env, 'production'
server 'tekniklr.com', user: 'tekniklr', roles: [:web, :app]
set :deploy_to, "/home/tekniklr/rails.tekniklr.com"
set :branch, 'main'
set :tmp_dir, "/home/tekniklr/tmp"
set :rvm_type, :user
set :rvm_ruby_version, 'default'
set :ssh_options, {
  forward_agent: true
}
set :use_sudo, false
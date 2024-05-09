set :rails_env, 'production'
server 'tekniklr.com', user: 'tekniklr', roles: [:web, :app]
set :deploy_to, "/home/tekniklr/rails.tekniklr.com"
set :branch, 'main'
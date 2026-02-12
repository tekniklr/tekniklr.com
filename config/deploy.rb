set :application, 'tekniklr.com'
set :repo_url,  "https://github.com/tekniklr/tekniklr.com.git"
set :linked_files, %w{config/master.key config/database.yml}
set :linked_dirs, %w{.bundle public/images public/icons public/recent_games public/favorite_things public/tabletop_games public/remote_cache public/.well-known tmp/pids tmp/sockets tmp/cache log}
set :bundle_version, 4
set :bundle_jobs, 1
set :keep_releases, 6
set :tmp_dir, "/home/tekniklr/tmp"
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-3.4.7'
set :ssh_options, {
  forward_agent: true
}
set :use_sudo, false
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_systemctl_bin, '/usr/bin/systemctl'
set :puma_service_unit_name, "puma"
set :puma_systemctl_user, :user

before 'deploy:updated', 'deploy:stop'
namespace :deploy do
  task :stop do
    invoke 'delayed_job:stop'
  end
end

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'delayed_job:restart'
  end
end
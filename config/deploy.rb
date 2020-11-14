set :application, 'tekniklr.com'
set :repo_url,  "https://github.com/tekniklr/tekniklr.com.git"
set :linked_files, %w{config/master.key config/database.yml}
set :linked_dirs, %w{public/wpblog public/images public/icons public/recent_games public/favorite_things public/tabletop_games public/.well-known tmp/pids}
set :keep_releases, 12

namespace :deploy do

  after :publishing, :tekniklr_com do
    invoke "tekniklr_com:wptheme"
    invoke "delayed_job:kill"
  end

  after :finished, :restart

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :delayed_job do
    invoke 'delayed_job:start'
  end

  after :finishing, :cleanup

end

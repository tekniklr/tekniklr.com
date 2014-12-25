# config valid only for Capistrano 3
lock '>=3.0'

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

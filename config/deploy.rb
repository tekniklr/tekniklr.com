# config valid only for Capistrano 3.1
lock '3.2.1'

namespace :deploy do

  after :publishing, :tekniklr_com do
    invoke "tekniklr_com:wptheme"
  end

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :finished, :restart

  after :restart, :delayed_job do
    invoke 'delayed_job:restart'
  end

  after :finishing, :cleanup

end

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy'
load 'deploy/assets'

namespace :deploy do

  desc "Link database.yml"
  task :link_database do
    run "rm -drf #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
  end

  desc "Link omniauth"
  task :link_omniauth do
    run "rm -drf #{release_path}/config/initializers/omniauth.rb"
    run "ln -s #{shared_path}/omniauth.rb #{release_path}/config/initializers/omniauth.rb"
  end

  desc "Link secret token"
  task :link_secret_token do
    run "rm -drf #{release_path}/config/initializers/secret_token.rb"
    run "ln -s #{shared_path}/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
  end
  
  desc "Link amazon"
  task :link_amazon do
    run "rm -drf #{release_path}/config/.amazonrc"
    run "ln -s #{shared_path}/amazonrc #{release_path}/config/.amazonrc"
  end

  desc "Link wordpress"
  task :link_wpblog do
    run "rm -drf #{release_path}/public/wpblog"
    run "ln -s #{shared_path}/wpblog #{release_path}/public/wpblog"
  end
  
  desc "Link legacy images"
  task :link_legacy do
    run "rm -drf #{release_path}/public/images"
    run "ln -s #{shared_path}/legacy/images #{release_path}/public/images"
  end
  
  desc "Passenger restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Update wordpress theme"
  task :wptheme do
    run "cd '#{shared_path}/wpblog/wp-content/themes/tekniklr.com/'; git pull"
  end
  
end

before 'deploy:finalize_update'

before "deploy:assets:precompile", "deploy:link_database", "deploy:link_omniauth", "deploy:link_secret_token", "deploy:link_amazon", "deploy:link_wpblog", "deploy:link_legacy", "deploy:wptheme"

before "deploy:restart", "delayed_job:stop"
after  "deploy:restart", "delayed_job:start"
after "deploy:stop",  "delayed_job:stop"
after "deploy:start", "delayed_job:start"

after "deploy:restart", "deploy:cleanup"
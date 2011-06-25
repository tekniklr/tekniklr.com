load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks

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
  task :link_secet_token do
    run "rm -drf #{release_path}/config/initializers/secret_token.rb"
    run "ln -s #{shared_path}/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
  end

  desc "Link wordpress"
  task :link_wpblog do
    run "rm -drf #{release_path}/public/wpblog"
    run "ln -s #{shared_path}/wpblog #{release_path}/public/wpblog"
  end
  
end

after "deploy:symlink", "deploy:link_database", "deploy:link_omniauth", "deploy:link_secret_token", "deploy:link_wpblog"
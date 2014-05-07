namespace :tekniklr_com do
  
  desc "Update wordpress theme"
  task :wptheme do
    on roles(:app) do
      within shared_path do
        execute "cd '/home/tekniklr/rails.tekniklr.com/shared/public/wpblog/wp-content/themes/tekniklr.com/'; git pull"
      end
    end
  end

end
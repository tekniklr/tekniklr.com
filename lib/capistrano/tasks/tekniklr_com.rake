namespace :tekniklr_com do
  
  desc "Update wordpress theme"
  task :wptheme do
    on roles(:web) do
      within shared_path do
        execute "cd '/home/tekniklr/blog.tekniklr.com/wp-content/themes/tekniklr.com/'; git pull"
      end
    end
  end

end
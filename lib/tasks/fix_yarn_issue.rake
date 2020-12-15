# From: https://github.com/barsoom/pipeline/commit/3906724b34b4803d815f9ab1252b6046d00b8821

# FIXME: Remove this file when https://github.com/rails/rails/issues/40795 has a fix.

#Rake::Task[ "yarn:install" ].clear
namespace :yarn do
  desc "Disabling internal yarn install from Rails"
  task install: :environment do
    puts "Disabling internal yarn install from Rails"
  end
end

#Rake::Task[ "webpacker:yarn_install" ].clear
namespace :webpacker do
  desc "Disabling internal yarn install from Rails"
  task yarn_install: :environment do
    puts "Disabling internal yarn install from Rails"
  end
end

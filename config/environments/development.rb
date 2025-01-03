Rails.application.configure do

  config.enable_reloading = true

  config.eager_load = false

  config.assets.quiet = true

  config.assets.debug = true

  config.assets.digest = false

  config.whiny_nils = true

  config.consider_all_requests_local = true

  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log
  
  config.logger = Logger.new(Rails.root.join("log",Rails.env + ".log"),1,5*1024*1024)
  
  Paperclip.options[:command_path] = "/opt/local/bin"

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    #config.cache_store = :memory_store
    config.cache_store = :file_store, "#{Rails.root}/tmp/cache"
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end
  
  #config.content_security_policy_report_only = true
end


Rails.application.configure do

  config.eager_load = false

  config.assets.compile = true

  config.assets.debug = true

  config.cache_classes = false

  config.whiny_nils = true

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log
  
  config.logger = Logger.new(Rails.root.join("logs",Rails.env + ".log"),1,5*1024*1024)
  
  Paperclip.options[:command_path] = "/opt/local/bin"
  
  #config.content_security_policy_report_only = true
end


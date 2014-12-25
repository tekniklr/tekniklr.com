TekniklrCom::Application.configure do

  config.eager_load = false

  config.cache_classes = false

  config.active_record.raise_in_transactional_callbacks = true

  config.whiny_nils = true

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log
  
  config.logger = Logger.new(Rails.root.join("log",Rails.env + ".log"),1,5*1024*1024)
  
  Paperclip.options[:command_path] = "/opt/local/bin"

  Rails.application.routes.default_url_options[:host] = '0.0.0.0:3000'
end


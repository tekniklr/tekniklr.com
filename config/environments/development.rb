TekniklrCom::Application.configure do

  config.cache_classes = false

  config.active_record.mass_assignment_sanitizer = :strict

  config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.whiny_nils = true

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

  config.action_dispatch.best_standards_support = :builtin
  
  config.logger = Logger.new(Rails.root.join("log",Rails.env + ".log"),1,5*1024*1024)
  
  Paperclip.options[:command_path] = "/opt/local/bin"

  Rails.application.routes.default_url_options[:host] = '0.0.0.0:3000'
end


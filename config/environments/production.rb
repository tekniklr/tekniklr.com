TekniklrCom::Application.configure do

  config.eager_load = true

  config.log_level = :info

  config.active_record.raise_in_transactional_callbacks = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local        = false
  config.action_controller.perform_caching  = true
  config.action_view.cache_template_loading = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = true

  # Compress both stylesheets and JavaScripts
  # config.assets.js_compressor  = :uglifier

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new
  config.logger = Logger.new(Rails.root.join("log",Rails.env + ".log"),10,5*1024*1024)

  # Use a different cache store in production
  #config.cache_store = :memory_store
  config.cache_store = :file_store, "#{Rails.root}/tmp/cache"
  
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  TekniklrCom::Application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => "[tekniklr.com] ",
    :sender_address => %{tsolow@tekniklr.com},
    :exception_recipients => %w{tsolow@tekniklr.com}
  }

  Rails.application.routes.default_url_options[:host] = 'tekniklr.com'

end

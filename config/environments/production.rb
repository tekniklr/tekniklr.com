Rails.application.configure do

  config.eager_load = true

  config.log_level = :info

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local        = false
  config.action_controller.perform_caching  = true
  config.action_view.cache_template_loading = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.public_file_server.enabled = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Generate digests for assets URLs
  config.assets.digest = true 

  # Compress both stylesheets and JavaScripts
  config.assets.js_compressor = :terser

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  #config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx

  # specify log location, keep at least 10 rotated logs, rotate every 5MB
  config.logger = ActiveSupport::Logger.new(Rails.root.join("log",Rails.env+".log"),10,5*1024*1024)

  # Use a different cache store in production
  #config.cache_store = :memory_store
  config.cache_store = :file_store, "#{Rails.root}/tmp/cache"
  
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: -> request { request.host =~ /tekniklr\.pizza/ } } }

  config.action_controller.asset_host = 'https://tekniklr.com'

  config.middleware.use ExceptionNotification::Rack,
    ignore_exceptions:  [
                          'ActionController::BadRequest',
                          'ActionController::InvalidCrossOriginRequest',
                          'Mime::Type::InvalidMimeType'
                        ] + ExceptionNotifier.ignored_exceptions,
    ignore_crawlers:    %w{Uptimebot},
    email: {
      email_prefix:          "[tekniklr.com] ",
      sender_address:        %{rails@tekniklr.com},
      exception_recipients:  %w{rails@tekniklr.com}
    }

end

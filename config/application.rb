require File.expand_path('../boot', __FILE__)

require "rails"

# Include each railties manually, excluding cruft (from https://stackoverflow.com/questions/49813214/disable-active-storage-in-rails-5-2 )
%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  rails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

module TekniklrCom
  class Application < Rails::Application
    config.autoload_paths += %W(#{Rails.root}/lib)
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.assets.version = '1.2'
    config.i18n.enforce_available_locales = false
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false
    config.active_record.belongs_to_required_by_default = true
    config.action_controller.forgery_protection_origin_check = true
    config.active_job.queue_adapter = :delayed_job
  end
end

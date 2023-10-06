require File.expand_path('../boot', __FILE__)

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "active_support/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

module TekniklrCom
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_once_paths += %W(#{Rails.root}/lib)
    config.encoding = "utf-8"
    config.i18n.enforce_available_locales = false
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false
    config.active_record.belongs_to_required_by_default = true
    config.action_controller.forgery_protection_origin_check = true
    config.active_job.queue_adapter = :delayed_job
    config.assets.paths << Rails.root.join('node_modules')
  end
end

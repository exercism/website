require_relative 'boot'

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Remove Rails things we don't use
# require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Website
  class Application < Rails::Application
    config.load_defaults 6.0

    config.active_job.queue_adapter = :delayed_job

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    config.generators do |g|
      g.assets false
      g.helper false
    end
  end
end

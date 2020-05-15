require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Exercism
  class Application < Rails::Application
    config.load_defaults 6.0

    config.active_job.queue_adapter = :delayed_job

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
  end
end

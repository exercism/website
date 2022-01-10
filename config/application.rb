require_relative 'boot'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Website
  class Application < Rails::Application
    config.load_defaults 7.0

    config.active_job.queue_adapter = :sidekiq

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
    config.action_view.form_with_generates_remote_forms = false

    config.exceptions_app = self.routes

    config.generators do |g|
      g.assets false
      g.helper false
    end

    Rails.autoloaders.main.ignore(Rails.root.join('app', 'css'))
  end
end

require_relative 'boot'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../app/middleware/restore_if_none_match_header'

module Website
  class Application < Rails::Application
    config.load_defaults 7.0

    config.active_job.queue_adapter = :sidekiq

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
    config.action_view.form_with_generates_remote_forms = false

    # For some reason, the default queue (mailers) is not used so we
    # need to explicitly set it here
    config.action_mailer.deliver_later_queue_name = 'mailers'

    config.exceptions_app = self.routes

    config.generators do |g|
      g.assets false
      g.helper false
    end

    config.middleware.use Rack::CrawlerDetect
    config.middleware.insert_after Rack::Runtime, Rack::ContentLength

    # Allow SVGs to render from active storage
    config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']

    Rails.autoloaders.main.ignore(Rails.root.join('app', 'css'))
  end
end

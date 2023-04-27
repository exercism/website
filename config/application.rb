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

    # For some reason, the default queue (mailers) is not used so we
    # need to explicitly set it here
    config.action_mailer.deliver_later_queue_name = 'mailers'

    config.exceptions_app = self.routes

    # Allow rails to run queries in parallel
    config.active_record.async_query_executor = :global_thread_pool

    config.generators do |g|
      g.assets false
      g.helper false
    end

    Rails.autoloaders.main.ignore(Rails.root.join('app', 'css'))
  end
end

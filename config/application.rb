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

    config.generators do |g|
      g.assets false
      g.helper false
    end

    config.middleware.use Rack::CrawlerDetect
    config.middleware.insert_after Rack::Runtime, Rack::ContentLength

    # Allow SVGs to render from active storage
    config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']

    # Public assets (partner logos, avatars) are hit on every page load, so
    # they need to be cacheable at the edge. The default blob *redirect*
    # endpoint can never be: it 302s to a presigned S3 URL, so Rails marks the
    # redirect `private` and caps its max-age at the signature's lifetime.
    #
    # Proxying instead means the URL is permanent and the response is served
    # with `public, max-age=<forever>` (ActiveStorage::Blobs::ProxyController),
    # so Cloudflare fetches each blob once and never asks again.
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Still relevant for anything that asks a blob for its service URL directly
    # (direct downloads, the admin UI) rather than going through a route.
    config.active_storage.service_urls_expire_in = 1.day

    Rails.autoloaders.main.ignore(Rails.root.join('app', 'css'))
  end
end

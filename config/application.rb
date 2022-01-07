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

# Rails.application.config.to_prepare do
#   puts "to_prepare"

#   module Propshaft
#     LoadPath.class_eval do
#       def cache_sweeper
#         puts "my cache sweeper"
#         @cache_sweeper ||= begin
#           puts "paths: #{paths}"

#           exts_to_watch  = Mime::EXTENSION_LOOKUP.map(&:first)
#           files_to_watch = Array(paths).collect { |dir| [ dir.to_s, exts_to_watch ] }.to_h
#           puts "files_to_watch: #{files_to_watch}"
#           Rails.application.config.file_watcher.new([], files_to_watch) do
#             "clear cache"
#             clear_cache
#           end
#         end
#       end
#     end
#   end
# end

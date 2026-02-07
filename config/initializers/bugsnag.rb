BUGSNAG_ACTIVE_STORAGE_FILTER = proc do |event|
  next if event.errors.empty?

  error_class = event.errors.first.error_class
  request_url = event.request&.dig(:url) || ''

  next false if error_class == 'ActiveRecord::RecordNotFound' && request_url.include?('/rails/active_storage/')
end

if Rails.env.production?
  Bugsnag.configure do |config|
    config.api_key = "5564ad0d9fde96c4378bc555eaf88313"
    config.notify_release_stages = ["production"]

    config.add_on_error(BUGSNAG_ACTIVE_STORAGE_FILTER)
  end
end

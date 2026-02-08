SENTRY_ACTIVE_STORAGE_FILTER = lambda do |event, hint|
  exception = hint[:exception]
  return event unless exception.is_a?(ActiveRecord::RecordNotFound)

  request_url = event.request&.url || ''
  return nil if request_url.include?('/rails/active_storage/')

  event
end

if Rails.env.production?
  Sentry.init do |config|
    config.dsn = Exercism.config.sentry_dsn
    config.environment = Rails.env
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.send_default_pii = false
    config.excluded_exceptions += ['ActiveRecord::Deadlocked']
    config.before_send = SENTRY_ACTIVE_STORAGE_FILTER
  end
end

Sidekiq.configure_server do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }
end

Sidekiq.configure_server do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }
end

if Sidekiq.server?
  data = YAML.load_file(Rails.root.join("config", "sidekiq-schedule.yml"))
  Sidekiq::Cron::Job.load_from_hash(data)
end

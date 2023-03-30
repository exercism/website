require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }

  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(Rails.root.join('config', 'sidekiq-schedule.yml'))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end

  config.logger.level = Logger::WARN
end

Sidekiq.configure_client do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }
end

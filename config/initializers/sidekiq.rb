require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }

  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(Rails.root.join('config', 'sidekiq-schedule.yml'))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end

  config.logger.level = Logger::WARN

  # The analytics jobs call PostHog. They run in their own capsule with a
  # couple of threads, so if PostHog is slow or down, those jobs will only
  # hold up each other and every other queue keeps its threads. The queue is
  # deliberately left out of config/sidekiq.yml, so the default capsule
  # never picks these jobs up.
  config.capsule("analytics") do |capsule|
    capsule.concurrency = 2
    capsule.queues = %w[analytics]
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: Exercism.config.sidekiq_redis_url }
end

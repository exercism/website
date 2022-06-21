class Metric::Queue
  include Mandate

  initialize_with :action, :created_at, :attributes

  def call
    LogMetricJob.perform_later(action, created_at, **attributes)
  rescue StandardError
    # Don't crash if the creation fails, e.g. if sidekiq is down
  end
end

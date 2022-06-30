class Metric::Queue
  include Mandate

  initialize_with :type, :occurred_at, :attributes

  def call
    LogMetricJob.perform_later(type, occurred_at, **attributes)
  rescue StandardError
    # Don't crash if the creation fails, e.g. if sidekiq is down
  end
end

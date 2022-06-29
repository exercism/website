class LogMetricJob < ApplicationJob
  queue_as :metrics

  def perform(action, occurred_at, **attributes)
    Metric::Create.(action, occurred_at, **attributes)
  end
end

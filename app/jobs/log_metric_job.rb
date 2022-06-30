class LogMetricJob < ApplicationJob
  queue_as :metrics

  def perform(type, occurred_at, **attributes)
    Metric::Create.(type, occurred_at, **attributes)
  end
end

class LogMetricJob < ApplicationJob
  queue_as :metrics

  def perform(type, occurred_at, country_code, **attributes)
    Metric::Create.(type, occurred_at, country_code, **attributes)
  end
end

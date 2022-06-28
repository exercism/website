class LogMetricJob < ApplicationJob
  queue_as :dribble

  def perform(action, occurred_at, **attributes)
    Metric::Create.(action, occurred_at, **attributes)
  end
end

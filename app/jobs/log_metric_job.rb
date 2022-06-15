class LogMetricJob < ApplicationJob
  queue_as :dribble

  def perform(action, created_at, **attributes)
    Metric::Create.(action, created_at, **attributes)
  end
end

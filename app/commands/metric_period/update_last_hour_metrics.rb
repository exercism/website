class MetricPeriod::UpdateLastHourMetrics
  include Mandate

  def call
    60.times do |minute|
      MetricPeriod::UpdateMinuteMetrics.(Time.current.prev_min - minute.minutes)
    end
  end
end

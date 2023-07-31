class MetricPeriod::UpdateLastWeekMetrics
  include Mandate

  def call
    7.times do |day|
      MetricPeriod::UpdateDayMetrics.(Time.current.prev_day - day.days)
    end
  end
end

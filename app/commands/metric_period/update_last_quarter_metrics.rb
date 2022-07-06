class MetricPeriod::UpdateLastQuarterMetrics
  include Mandate

  def call
    3.times do |month|
      MetricPeriod::UpdateMonthMetrics.(Time.current.prev_month - month.months)
    end
  end
end

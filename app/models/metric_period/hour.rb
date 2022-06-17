class MetricPeriod::Hour < ApplicationRecord
  include HasMetricAction

  belongs_to :track, optional: true
end

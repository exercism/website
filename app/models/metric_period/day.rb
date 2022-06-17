class MetricPeriod::Day < ApplicationRecord
  include HasMetricAction

  belongs_to :track, optional: true
end

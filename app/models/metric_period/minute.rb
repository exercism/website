class MetricPeriod::Minute < ApplicationRecord
  include HasMetricAction

  belongs_to :track, optional: true
end

class MetricPeriod::Month < ApplicationRecord
  include HasMetricAction

  belongs_to :track, optional: true
end

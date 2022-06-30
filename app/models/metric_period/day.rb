class MetricPeriod::Day < ApplicationRecord
  belongs_to :track, optional: true
end

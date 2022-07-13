class MetricPeriod::Month < ApplicationRecord
  belongs_to :track, optional: true
end

class MetricPeriod::Minute < ApplicationRecord
  belongs_to :track, optional: true
end

class Metric < ApplicationRecord
  include HasMetricAction

  belongs_to :track, optional: true
  belongs_to :user, optional: true
end

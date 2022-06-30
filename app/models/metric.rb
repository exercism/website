class Metric < ApplicationRecord
  belongs_to :track, optional: true
  belongs_to :user, optional: true
end

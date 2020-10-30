class Iteration < ApplicationRecord
  belongs_to :solution
  belongs_to :submission

  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  before_create do
    self.uuid = SecureRandom.compact_uuid unless self.uuid
  end
end

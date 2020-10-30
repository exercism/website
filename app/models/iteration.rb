class Iteration < ApplicationRecord
  belongs_to :solution
  belongs_to :submission

  delegate :track, :exercise, to: :solution
end

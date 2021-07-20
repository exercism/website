class Mentor::RequestLock < ApplicationRecord
  belongs_to :request
  belongs_to :locked_by, class_name: "User"

  scope :expired, -> { where("locked_until < ?", Time.current) }

  MAX_LOCKS_PER_MENTOR = 2
end

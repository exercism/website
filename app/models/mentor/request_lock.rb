class Mentor::RequestLock < ApplicationRecord
  MAX_LOCKS_PER_MENTOR = 4

  belongs_to :request
  belongs_to :locked_by, class_name: "User"

  scope :expired, -> { where("locked_until < ?", Time.current) }
end

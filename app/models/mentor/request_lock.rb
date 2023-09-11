class Mentor::RequestLock < ApplicationRecord
  MAX_LOCKS_PER_MENTOR = 4

  belongs_to :request
  belongs_to :locked_by, class_name: "User"

  scope :expired, -> { where("locked_until < ?", Time.current) }

  def extend!(duration = 30.minutes)
    # TODO: Guard to check if lock is active.
    # If it's not, raise an exception.
    update!(locked_until: Time.current + duration)
  end
end

class Mentor::RequestLock < ApplicationRecord
  MAX_LOCKS_PER_MENTOR = 4

  belongs_to :request
  belongs_to :locked_by, class_name: "User"

  scope :expired, -> { where("locked_until < ?", Time.current) }

  def extend!(duration = 30.minutes)
    with_lock do
      raise RequestLockHasExpired if expired?

      update!(locked_until: Time.current + duration)
    end
  end

  def expired?
    locked_until < Time.current
  end
end

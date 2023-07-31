class Mentor::Testimonial < ApplicationRecord
  belongs_to :mentor, class_name: "User"
  belongs_to :student, class_name: "User"
  belongs_to :discussion, class_name: "Mentor::Discussion"
  has_one :solution, through: :discussion
  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  before_create do
    self.uuid = SecureRandom.uuid unless self.uuid
  end

  scope :not_deleted, -> { where(deleted_at: nil) }

  # TODO: If we add publishing as a thing, then
  # honour that here too.
  scope :published, -> { revealed.not_deleted }

  scope :revealed, -> { where(revealed: true) }
  scope :unrevealed, -> { where(revealed: false) }

  # TODO: Move to command
  def soft_destroy!(time: Time.current)
    update!(deleted_at: time)
    User::ResetCache.defer(mentor, :num_testimonials)
  end
end

class Mentor::Request < ApplicationRecord
  disable_sti!

  enum status: { pending: 0, fulfilled: 1, cancelled: 2 }

  belongs_to :solution
  belongs_to :student, class_name: "User"
  belongs_to :exercise
  belongs_to :track

  belongs_to :locked_by, class_name: "User", optional: true
  has_one :discussion,
    inverse_of: :request, dependent: :nullify

  scope :locked, -> { where("locked_until > ?", Time.current) }
  scope :unlocked, lambda {
    where(locked_until: nil).
      or(where("locked_until < ?", Time.current))
  }
  scope :unlocked_for, lambda { |user|
    where(locked_by: user).or(unlocked)
  }

  validates :comment_markdown, presence: true

  has_markdown_field :comment

  delegate :title, to: :track, prefix: :track
  delegate :handle, :avatar_url, to: :student, prefix: :student
  delegate :title, :icon_url, to: :exercise, prefix: :exercise

  before_validation on: :create do
    self.student_id = solution.user_id
    self.track_id = solution.exercise.track_id
    self.exercise_id = solution.exercise_id
  end

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  after_create_commit do
    solution.update_mentoring_status!
  end

  after_save_commit do
    solution.update_mentoring_status! if previous_changes.key?('status')
  end

  def to_param
    uuid
  end

  def status
    super.to_sym
  end

  def type
    super.to_sym
  end

  # If this request is locked by someone else then
  # the user has timed out and someone else has started
  # work on this solution, which is a mess.
  #
  # If the solution isn't locked at all then the person timed
  # out but no-one else claimed it so let's carry on
  def lockable_by?(mentor)
    (pending? && !locked?) || locked_by == mentor
  end

  def locked?
    locked_until.present? && Time.current < locked_until
  end
end

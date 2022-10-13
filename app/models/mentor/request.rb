class Mentor::Request < ApplicationRecord
  disable_sti!

  enum status: { pending: 0, fulfilled: 1, cancelled: 2 }

  belongs_to :solution
  belongs_to :student, class_name: "User"
  belongs_to :exercise
  belongs_to :track

  has_many :locks, class_name: "Mentor::RequestLock", dependent: :destroy
  has_many :iterations, through: :solution

  # Needed for deletion
  has_many :discussions, dependent: :nullify

  has_one :discussion,
    inverse_of: :request,
    dependent: :nullify

  scope :locked, lambda {
    where("EXISTS(SELECT NULL FROM mentor_request_locks
                  WHERE mentor_request_locks.request_id = mentor_requests.id)")
  }

  scope :unlocked, lambda {
    where("NOT EXISTS(SELECT NULL FROM mentor_request_locks
                      WHERE mentor_request_locks.request_id = mentor_requests.id)")
  }
  scope :unlocked_for, lambda { |user|
    where("NOT EXISTS(SELECT NULL FROM mentor_request_locks
                      WHERE mentor_request_locks.request_id = mentor_requests.id
                      AND locked_by_id != ?)", user.id)
  }

  validates :comment_markdown, presence: true, if: :validate_comment_markdown?
  attr_accessor :v2

  has_markdown_field :comment, strip_h1: false, lower_heading_levels_by: 2

  delegate :title, :slug, to: :track, prefix: :track
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

  def to_param = uuid
  def status = super.to_sym
  def type = super.to_sym

  # If this request is locked by someone else then
  # the user has timed out and someone else has started
  # work on this solution, which is a mess.
  #
  # If the solution isn't locked at all then the person timed
  # out but no-one else claimed it so let's carry on
  def lockable_by?(mentor)
    return false unless pending?

    latest_lock = locks.last
    return true unless latest_lock

    latest_lock.locked_by == mentor
  end

  def locked? = locks.exists?

  def comment
    Mentor::RequestComment.from(self)
  end

  def validate_comment_markdown?
    return false if v2
    return true if new_record?

    changed_attributes.key?("comment_markdown")
  end
end

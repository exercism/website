class Mentor::Discussion < ApplicationRecord
  enum status: {
    awaiting_student: 0,
    awaiting_mentor: 1,
    mentor_finished: 2,
    student_finished: 3,
    both_finished: 4
  }

  belongs_to :solution
  has_one :student, through: :solution, source: :user
  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  belongs_to :mentor, class_name: "User"
  belongs_to :request, optional: true

  has_many :posts, class_name: "DiscussionPost",
                   dependent: :destroy,
                   inverse_of: :discussion
  has_many :iterations, through: :solution

  scope :in_progress_for_student, -> { where(status: %i[awaiting_student awaiting_mentor mentor_finished]) }
  scope :finished_for_student, -> { where(status: %i[student_finished both_finished]) }
  scope :finished_for_mentor, -> { where(status: %i[mentor_finished both_finished]) }

  before_validation do
    self.solution = request.solution unless self.solution
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

  delegate :title, :icon_url, to: :track, prefix: :track
  delegate :handle, :avatar_url, to: :student, prefix: :student
  delegate :title, to: :exercise, prefix: :exercise

  def status
    super.to_sym
  end

  def student_mentor_relationship
    Mentor::StudentRelationship.find_by(mentor: mentor, student: student)
  end

  def student_url
    Exercism::Routes.track_exercise_mentor_discussion_url(
      track, exercise, self
    )
  end

  def mentor_url
    Exercism::Routes.mentoring_discussion_url(self)
  end

  def to_param
    uuid
  end

  def finished_for_student?
    %i[student_finished both_finished].include?(status)
  end

  def finished_for_mentor?
    %i[mentor_finished both_finished].include?(status)
  end

  def viewable_by?(user)
    # TODO: Admins should also be allowed to view
    [mentor, student].include?(user)
  end

  def awaiting_student!
    update_columns(
      status: :awaiting_student,
      awaiting_mentor_since: nil,
      awaiting_student_since: awaiting_student_since || Time.current
    )
  end

  def awaiting_mentor!
    update_columns(
      status: :awaiting_mentor,
      awaiting_mentor_since: awaiting_mentor_since || Time.current,
      awaiting_student_since: nil
    )
  end
end

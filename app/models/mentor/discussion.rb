class Mentor::Discussion < ApplicationRecord
  NUM_DAYS_BEFORE_TIME_OUT = 28
  DAYS_BEFORE_TIME_OUT = NUM_DAYS_BEFORE_TIME_OUT.days

  enum status: {
    awaiting_student: 0,
    awaiting_mentor: 1,
    mentor_finished: 2,
    finished: 4,
    student_timed_out: 5,
    mentor_timed_out: 6
  }

  enum finished_by: {
    mentor: 1,
    student: 2,
    student_timed_out: 3,
    mentor_timed_out: 4
  }, _suffix: true

  enum rating: {
    great: 5,
    good: 4,
    acceptable: 3,
    problematic: 1
  }

  belongs_to :solution
  has_one :student, through: :solution, source: :user
  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  belongs_to :mentor, class_name: "User"
  belongs_to :request, optional: true

  has_many :posts, class_name: "DiscussionPost", dependent: :destroy, inverse_of: :discussion
  has_many :iterations, through: :solution

  scope :in_progress_for_student, -> { where(status: %i[awaiting_student awaiting_mentor mentor_finished]) }
  scope :finished_for_student, -> { where(status: :finished) }
  scope :finished_for_mentor, -> { where(status: %i[mentor_finished finished student_timed_out mentor_timed_out]) }
  scope :not_negatively_rated, -> { where(rating: [nil, :acceptable, :good, :great]) }

  def self.between(mentor:, student:)
    joins(:solution).
      where('solutions.user_id': student.id).
      where(mentor_id: mentor.id)
  end

  before_validation do
    self.solution = request.solution unless self.solution
  end

  before_create do
    self.uuid = SecureRandom.compact_uuid if self.uuid.blank?
  end

  after_create_commit do
    solution.update_mentoring_status!
  end

  after_save_commit do
    solution.update_mentoring_status! if previous_changes.key?('status')
  end

  delegate :title, :icon_url, to: :track, prefix: :track
  delegate :title, to: :exercise, prefix: :exercise
  delegate :comment, to: :request, prefix: true, allow_nil: true

  def status = super.to_sym

  %i[finished_by rating].each do |meth|
    define_method meth do
      super()&.to_sym
    end
  end

  def student_mentor_relationship
    Mentor::StudentRelationship.find_by(mentor:, student:)
  end

  def student_url
    Exercism::Routes.track_exercise_mentor_discussion_url(
      track, exercise, self
    )
  end

  def mentor_url
    Exercism::Routes.mentoring_discussion_url(self)
  end

  def to_param = uuid
  def finished_for_student? = status == :finished
  def finished_for_mentor? = %i[mentor_finished finished student_timed_out mentor_timed_out].include?(status)
  def timed_out? = %i[student_timed_out mentor_timed_out].include?(status)

  def viewable_by?(user)
    return true if user.admin?

    [mentor, student].include?(user)
  end

  def viewable_by_mentor?(user)
    return true if user.admin?

    user == mentor
  end

  def student_handle = anonymous_mode? ? "anonymous" : student.handle
  def student_flair = anonymous_mode? ? "anonymous" : student.flair
  def student_name = anonymous_mode? ? "User in Anonymous mode" : student.name
  def student_avatar_url = anonymous_mode? ? nil : student.avatar_url
end

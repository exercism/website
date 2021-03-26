class Mentor::Discussion < ApplicationRecord
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

  scope :finished, -> { where.not(finished_at: nil) }
  scope :in_progress, -> { where(finished_at: nil) }

  scope :requires_mentor_action, -> { where.not(requires_mentor_action_since: nil) }
  scope :requires_student_action, -> { where.not(requires_student_action_since: nil) }

  before_validation do
    self.solution = request.solution unless self.solution
  end

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  delegate :title, :icon_url, to: :track, prefix: :track
  delegate :handle, :avatar_url, to: :student, prefix: :student
  delegate :title, to: :exercise, prefix: :exercise

  def student_mentor_relationship
    Mentor::StudentRelationship.find_by(mentor: mentor, student: student)
  end

  def to_param
    uuid
  end

  def finished?
    finished_at.present?
  end

  def viewable_by?(user)
    # TODO: Admins should also be allowed to view
    [mentor, student].include?(user)
  end

  def mentor_action_not_required!
    update_column(:requires_mentor_action_since, nil)
  end

  def requires_mentor_action?
    requires_mentor_action_since.present?
  end
end

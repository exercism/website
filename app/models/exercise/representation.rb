class Exercise::Representation < ApplicationRecord
  serialize :mapping, JSON
  has_markdown_field :feedback

  belongs_to :exercise
  belongs_to :source_submission, class_name: "Submission"
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"
  belongs_to :track, optional: true
  has_one :solution, through: :source_submission

  enum feedback_type: { essential: 0, actionable: 1, non_actionable: 2, celebratory: 3 }, _prefix: :feedback
  enum draft_feedback_type: { essential: 0, actionable: 1, non_actionable: 2, celebratory: 3 }, _prefix: :draft_feedback

  has_many :submission_representations,
    foreign_key: :exercise_id_and_ast_digest_idx_cache,
    primary_key: :exercise_id_and_ast_digest_idx_cache,
    class_name: "Submission::Representation",
    inverse_of: :exercise_representation
  # This is too inefficient. Get the representations and then their submissions instead.
  # has_many :submission_representation_submissions, through: :submission_representations, source: :submission

  scope :without_feedback, -> { where(feedback_type: nil) }
  scope :with_feedback, -> { where.not(feedback_type: nil) }
  scope :with_feedback_by, ->(mentor) { where(feedback_author: mentor) }
  scope :mentored_by, ->(mentor) { where(submission_representations: mentor.submission_representations) }
  scope :for_track, ->(track) { where(track:) }

  delegate :analyzer_feedback, to: :source_submission

  before_create do
    self.uuid = SecureRandom.compact_uuid
    self.track_id = exercise.track_id
    self.exercise_id_and_ast_digest_idx_cache = "#{exercise_id}|#{ast_digest}"
  end

  def to_param = uuid
  def feedback_type = super&.to_sym
  def draft_feedback_type = super&.to_sym
  def num_times_used = submission_representations.count

  def has_essential_feedback? = has_feedback? && feedback_essential?
  def has_actionable_feedback? = has_feedback? && feedback_actionable?
  def has_non_actionable_feedback? = has_feedback? && feedback_non_actionable?
  def has_celebratory_feedback? = has_feedback? && feedback_celebratory?

  def has_feedback?
    [feedback_markdown, feedback_author_id, feedback_type].all?(&:present?)
  end

  def appears_frequently? = num_submissions >= APPEARS_FREQUENTLY_MIN_NUM_SUBMISSIONS

  APPEARS_FREQUENTLY_MIN_NUM_SUBMISSIONS = 5
  private_constant :APPEARS_FREQUENTLY_MIN_NUM_SUBMISSIONS
end

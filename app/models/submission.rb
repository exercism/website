class Submission < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :solution
  has_one :exercise, through: :solution
  has_one :track, through: :exercise
  has_one :iteration, dependent: :destroy

  has_many :files, class_name: "Submission::File", dependent: :destroy
  has_one :test_run, class_name: "Submission::TestRun", dependent: :destroy
  has_one :analysis, class_name: "Submission::Analysis", dependent: :destroy
  has_one :submission_representation, class_name: "Submission::Representation", dependent: :destroy
  has_one :exercise_representation, through: :submission_representation

  # TODO: Find a better name for the 0 state for these to represent something where no action has been taken.
  enum tests_status: { not_queued: 0, queued: 1, passed: 2, failed: 3, errored: 4, exceptioned: 5, cancelled: 6 }, _prefix: "tests" # rubocop:disable Layout/LineLength
  enum representation_status: { not_queued: 0, queued: 1, generated: 2, exceptioned: 3, cancelled: 5 }, _prefix: "representation" # rubocop:disable Layout/LineLength
  enum analysis_status: { not_queued: 0, queued: 1, completed: 3, exceptioned: 4, cancelled: 5 }, _prefix: "analysis" # rubocop:disable Layout/LineLength

  before_create do
    self.git_slug = solution.git_slug
    self.git_sha = solution.git_sha
  end

  def to_param
    uuid
  end

  def broadcast!
    SubmissionChannel.broadcast!(self)
  end

  # TODO: Delete this
  # def serialized
  #   tests_data = tests_status
  #   if tests_exceptioned?
  #     job = ToolingJob.find(test_run.tooling_job_id, full: true)
  #     tests_data += "\n\n\nSTDOUT:\n------\n#{job.stdout}"
  #     tests_data += "\n\n\nSTDERR:\n------\n#{job.stderr}"
  #   end

  #   representer_data = representation_status
  #   if representation_exceptioned?
  #     job = ToolingJob.find(submission_representation.tooling_job_id, full: true)
  #     representer_data += "\n\n\nSTDOUT:\n------\n#{job.stdout}"
  #     representer_data += "\n\n\nSTDERR:\n------\n#{job.stderr}"
  #   end

  #   analyzer_data = analysis_status
  #   if analysis_exceptioned?
  #     job = ToolingJob.find(analysis.tooling_job_id, full: true)
  #     analyzer_data += "\n\n\nSTDOUT:\n------\n#{job.stdout}"
  #     analyzer_data += "\n\n\nSTDERR:\n------\n#{job.stderr}"
  #   end
  # end

  memoize
  def has_automated_feedback?
    exercise_representation&.has_feedback? || analysis&.has_feedback?
  end

  memoize
  def automated_feedback
    feedback = []
    feedback << exercise_representation if exercise_representation&.has_feedback?
    feedback
  end

  def viewable_by?(user)
    solution.mentors.include?(user)
  end
end

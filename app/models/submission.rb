class Submission < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :solution
  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  has_many :files, class_name: "Submission::File", dependent: :destroy
  has_one :test_run, class_name: "Submission::TestRun", dependent: :destroy
  has_one :analysis, class_name: "Submission::Analysis", dependent: :destroy
  has_one :submission_representation, class_name: "Submission::Representation", dependent: :destroy

  enum tests_status: { not_queued: 0, queued: 1, passed: 2, failed: 3, errored: 4, exceptioned: 5, cancelled: 6 }, # rubocop:disable Layout/LineLength
       _prefix: "tests"

  # TODO: Find a better name for the 0 state here to represent something where no action has been taken.
  enum representation_status: { not_queued: 0, queued: 1, approved: 2, disapproved: 3, inconclusive: 4, exceptioned: 5, cancelled: 6 }, # rubocop:disable Layout/LineLength
       _prefix: "representation"

  # TODO: Find a better name for the 0 state here to represent something where no action has been taken.
  enum analysis_status: { not_queued: 0, queued: 1, approved: 2, disapproved: 3, inconclusive: 4, exceptioned: 5, cancelled: 6 }, # rubocop:disable Layout/LineLength
       _prefix: "analysis"

  before_create do
    self.git_slug = solution.git_slug
    self.git_sha = solution.git_sha
  end

  def to_param
    uuid
  end

  def broadcast!
    SubmissionsChannel.broadcast!(solution)
    SubmissionChannel.broadcast!(self)
  end

  def serialized
    tests_data = tests_status
    if tests_exceptioned?
      job = ToolingJob.find(test_run.tooling_job_id, full: true)
      tests_data += "\n\n\nSTDOUT:\n------\n#{job.stdout}"
      tests_data += "\n\n\nSTDERR:\n------\n#{job.stderr}"
    end

    {
      id: id,
      track: track.title,
      exercise: exercise.title,
      testsStatus: tests_data,
      representationStatus: representation_status,
      analysisStatus: analysis_status
    }
  end

  memoize
  def exercise_representation
    Rails.logger.warn "Calling exercise_representation on a submission may cause n+1s"

    return nil unless submission_representation&.ops_success?

    submission_representation&.exercise_representation
  rescue ActiveRecord::RecordNotFound
    nil
  end

  memoize
  def has_automated_feedback?
    Rails.logger.warn "Calling has_automated_feedback? on a submission may cause n+1s"
    exercise_representation&.has_feedback?
  end

  memoize
  def automated_feedback
    feedback = []
    feedback << exercise_representation if has_automated_feedback?
    feedback
  end
end

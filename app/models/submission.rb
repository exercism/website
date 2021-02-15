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

  # TODO: It's important that we enforce rules on these to stop things from
  # going from the success states (passed/failed/errored/generated/completed)
  # backwards to the pending states.

  # TODO: Find a better name for the 0 state for these to represent something where no action has been taken.
  enum tests_status: { not_queued: 0, queued: 1, passed: 2, failed: 3, errored: 4, exceptioned: 5, cancelled: 6 }, _prefix: "tests" # rubocop:disable Layout/LineLength
  enum representation_status: { not_queued: 0, queued: 1, generated: 2, exceptioned: 3, cancelled: 5 }, _prefix: "representation" # rubocop:disable Layout/LineLength
  enum analysis_status: { not_queued: 0, queued: 1, completed: 3, exceptioned: 4, cancelled: 5 }, _prefix: "analysis"

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
  def automated_feedback_status
    # If they're both still waiting, then return pending
    # TODO: If we don't have an analyzer we may currently never get here,
    # so we need to handle the missing analyzer sceneraio. Check this works ok.
    return :pending if !representation_generated? && !analysis_completed?

    # If either has feedback then we're present
    return :present if exercise_representation&.has_feedback? || analysis&.has_feedback?

    # Otherwise if either are still queued then we're pending
    return :pending if representation_queued? || representation_not_queued? ||
                       analysis_queued? || analysis_not_queued?

    # Otherwise we don't have feedback
    :none
  end

  memoize
  def automated_feedback
    return nil unless has_automated_feedback?

    {
      mentor: representer_feedback,
      analyzer: analyzer_feedback
    }
  end

  memoize
  def has_automated_feedback?
    automated_feedback_status == :present
  end

  def viewable_by?(user)
    solution.mentors.include?(user) || solution.user == user
  end

  private
  memoize
  def representer_feedback
    return nil unless exercise_representation&.has_feedback?

    author = exercise_representation.feedback_author

    {
      html: exercise_representation.feedback_html,
      author: {
        name: author.name,
        reputation: author.reputation,
        avatar_url: author.avatar_url,
        profile_url: "#" # TODO
      }
    }
  end

  memoize
  def analyzer_feedback
    return nil unless analysis&.has_feedback?

    {
      html: analysis.feedback_html,
      team: {
        name: "The #{track.title} Analysis Team",
        link_url: "#" # TODO
      }
    }
  end
end

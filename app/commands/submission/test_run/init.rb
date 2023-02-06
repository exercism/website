class Submission::TestRun::Init
  include Mandate

  def initialize(submission, type: :submission, git_sha: nil, run_in_background: false)
    @submission = submission
    @type = type.to_sym
    @git_sha = git_sha || submission.git_sha
    @run_in_background = !!run_in_background
  end

  def call
    ToolingJob::Create.(submission, :test_runner, git_sha:, run_in_background:).tap do
      update_status!
    end
  end

  private
  attr_reader :submission, :git_sha, :type, :run_in_background

  delegate :solution, to: :submission

  # rubocop:disable Style/IfUnlessModifier
  # rubocop:disable Style/GuardClause
  def update_status!
    return submission.tests_queued! unless type == :solution

    if submission == solution.latest_submission
      submission.solution.update_latest_iteration_head_tests_status!(:queued)
    end

    if submission == solution.latest_published_iteration_submission
      submission.solution.update_published_iteration_head_tests_status!(:queued)
    end
  end
  # rubocop:enable Style/GuardClause
  # rubocop:enable Style/IfUnlessModifier
end

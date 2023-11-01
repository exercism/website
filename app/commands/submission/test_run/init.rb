class Submission::TestRun::Init
  include Mandate

  def initialize(submission, git_sha: nil, run_in_background: false)
    @submission = submission
    @git_sha = git_sha || submission.git_sha
    @run_in_background = !!run_in_background
  end

  def call
    return unless solution.exercise.has_test_runner?

    ToolingJob::Create.(submission, :test_runner, git_sha:, run_in_background:).tap do
      update_status!
    end
  end

  private
  attr_reader :submission, :git_sha, :run_in_background

  delegate :solution, to: :submission

  # rubocop:disable Style/IfUnlessModifier
  # rubocop:disable Style/GuardClause
  def update_status!
    # Only set statuses if we're testing a solution against its own sha
    # rather than running head test runs.
    return unless git_sha == submission.git_sha

    submission.tests_queued!

    if submission == solution.latest_iteration_submission
      Solution::UpdateLatestIterationHeadTestsStatus.(solution, :queued)
    end

    if submission == solution.latest_published_iteration_submission
      Solution::UpdatePublishedIterationHeadTestsStatus.(solution, :queued)
    end
  end
  # rubocop:enable Style/GuardClause
  # rubocop:enable Style/IfUnlessModifier
end

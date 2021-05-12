require 'test_helper'

class ToolingJob::CancelTest < ActiveSupport::TestCase
  test "cancels test runner job" do
    redis = Exercism.redis_tooling_client

    submission = create :submission
    job = Submission::TestRun::Init.(submission)
    assert_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_queued, 0) # Sanity

    ToolingJob::Cancel.(submission.uuid, :test_runner)

    assert_nil redis.lindex(Exercism::ToolingJob.key_for_queued, 0)
    assert_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_cancelled, 0)
  end

  test "set tests status to cancelled" do
    submission = create :submission
    create_test_runner_job!(submission)

    ToolingJob::Cancel.(submission.uuid, :test_runner)

    assert submission.reload.tests_cancelled?
  end

  test "cancels analysis job" do
    submission = create :submission
    job = create_tooling_job!(submission, :analyzer)

    ToolingJob::Cancel.(submission.uuid, :analyzer)

    redis = Exercism.redis_tooling_client
    assert_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_cancelled, 0)
  end

  test "set analysis status to cancelled" do
    submission = create :submission
    create_tooling_job!(submission, :analyzer)

    ToolingJob::Cancel.(submission.uuid, :analyzer)

    assert submission.reload.analysis_cancelled?
  end

  test "cancels representation job" do
    submission = create :submission
    job = create_tooling_job!(submission, :representer)

    ToolingJob::Cancel.(submission.uuid, :representer)

    redis = Exercism.redis_tooling_client
    assert_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_cancelled, 0)
  end

  test "set representation status to cancelled" do
    submission = create :submission
    create_tooling_job!(submission, :representer)

    ToolingJob::Cancel.(submission.uuid, :representer)

    assert submission.reload.representation_cancelled?
  end
end

require 'test_helper'

class ToolingJob::CancelTest < ActiveSupport::TestCase
  test "cancels test runner job" do
    submission = create_submission
    job = create_test_runner_job!(submission)

    ToolingJob::Cancel.(submission.uuid, :test_runner)

    assert_equal "cancelled", dynamodb_job_status(job.id)
  end

  test "set tests status to cancelled" do
    submission = create_submission
    create_test_runner_job!(submission)

    ToolingJob::Cancel.(submission.uuid, :test_runner)

    assert submission.reload.tests_cancelled?
  end

  test "cancels analysis job" do
    submission = create_submission
    job = create_tooling_job!(submission, :analyzer)

    ToolingJob::Cancel.(submission.uuid, :analyzer)

    assert_equal "cancelled", dynamodb_job_status(job.id)
  end

  test "set analysis status to cancelled" do
    submission = create_submission
    create_tooling_job!(submission, :analyzer)

    ToolingJob::Cancel.(submission.uuid, :analyzer)

    assert submission.reload.analysis_cancelled?
  end

  test "cancels representation job" do
    submission = create_submission
    job = create_tooling_job!(submission, :representer)

    ToolingJob::Cancel.(submission.uuid, :representer)

    assert_equal "cancelled", dynamodb_job_status(job.id)
  end

  test "set representation status to cancelled" do
    submission = create_submission
    create_tooling_job!(submission, :representer)

    ToolingJob::Cancel.(submission.uuid, :representer)

    assert submission.reload.representation_cancelled?
  end

  private
  def create_submission
    solution = create :concept_solution
    create :submission, solution: solution
  end

  def dynamodb_job_status(id)
    attrs = read_from_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      { id: id },
      %i[job_status]
    )
    attrs["job_status"]
  end
end

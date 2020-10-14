require 'test_helper'

class ToolingJob::CancelTest < ActiveSupport::TestCase
  test "cancels test runner job" do
    submission = create_submission
    id = write_submission_to_dynamodb(submission, :test_runner)

    ToolingJob::Cancel.(submission.uuid, :test_runner)

    assert_equal "cancelled", dynamodb_job_status(id)
  end

  test "set tests status to cancelled" do
    submission = create_submission
    write_submission_to_dynamodb(submission, :test_runner)

    ToolingJob::Cancel.(submission.uuid, :test_runner)

    assert submission.reload.tests_cancelled?
  end

  test "cancels analysis job" do
    submission = create_submission
    id = write_submission_to_dynamodb(submission, :analyzer)

    ToolingJob::Cancel.(submission.uuid, :analyzer)

    assert_equal "cancelled", dynamodb_job_status(id)
  end

  test "set analysis status to cancelled" do
    submission = create_submission
    write_submission_to_dynamodb(submission, :analyzer)

    ToolingJob::Cancel.(submission.uuid, :analyzer)

    assert submission.reload.analysis_cancelled?
  end

  test "cancels representation job" do
    submission = create_submission
    id = write_submission_to_dynamodb(submission, :representer)

    ToolingJob::Cancel.(submission.uuid, :representer)

    assert_equal "cancelled", dynamodb_job_status(id)
  end

  test "set representation status to cancelled" do
    submission = create_submission
    write_submission_to_dynamodb(submission, :representer)

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

  def write_submission_to_dynamodb(submission, type)
    SecureRandom.uuid.tap do |id|
      write_to_dynamodb(
        Exercism.config.dynamodb_tooling_jobs_table,
        {
          "id" => id,
          "type" => type,
          "submission_uuid" => submission.uuid,
          "execution_status" => "job-status",
          "job_status" => "queued",
          "output" => { "results.json" => "#{submission.id}/results.json" }
        }
      )
    end
  end
end

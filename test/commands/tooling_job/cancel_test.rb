require 'test_helper'

class ToolingJob::CancelTest < ActiveSupport::TestCase
  test "cancels test runner job" do
    iteration = create_iteration

    id = SecureRandom.uuid
    type = "test_runner"
    iteration_uuid = iteration.uuid
    execution_status = "job-status"
    s3_key = "#{id}/results.json"

    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "iteration_uuid" => iteration_uuid,
        "execution_status" => execution_status,
        "job_status" => "pending",
        "output" => { "results.json" => s3_key }
      }
    )

    ToolingJob::Cancel.(iteration.uuid, :test_runner)

    assert_equal "cancelled", dynamodb_job_status(id)
  end

  test "set tests status to cancelled" do
    # TODO: Fix this test
    skip

    iteration = create_iteration

    ToolingJob::Cancel.(iteration.uuid, :test_runner)

    assert iteration.reload.tests_cancelled?
  end

  test "cancels analysis job" do
    skip
    iteration = create_iteration

    # TODO: Check job has updated in dynamodb
    ToolingJob::Cancel.(iteration.uuid, :analysis)
  end

  test "set analysis status to cancelled" do
    # TODO: Fix this test
    skip

    iteration = create_iteration

    ToolingJob::Cancel.(iteration.uuid, :analysis)

    assert iteration.reload.analysis_cancelled?
  end

  test "cancels representation job" do
    skip
    iteration = create_iteration

    # TODO: Check job has updated in dynamodb
    ToolingJob::Cancel.(iteration.uuid, :analysis)
  end

  test "set representation status to cancelled" do
    # TODO: Fix this test
    skip

    iteration = create_iteration

    ToolingJob::Cancel.(iteration.uuid, :representation)

    assert iteration.reload.representation_cancelled?
  end

  private
  def create_iteration
    files = []
    solution = create :concept_solution
    Iteration::Create.(solution, files, :cli)
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

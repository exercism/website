require 'test_helper'

class ToolingJob::ProcessTest < ActiveSupport::TestCase
  test "proxies to test run" do
    submission = create :submission
    execution_status = "job-status"
    results = { 'some' => 'result' }
    job = create_test_runner_job!(
      submission,
      execution_status: execution_status,
      results: results
    )

    Submission::TestRun::Process.expects(:call).with(job)

    ToolingJob::Process.(job.id)
  end

  test "proxies to representer" do
    id = SecureRandom.uuid
    type = "representer"
    submission_uuid = "submission-uuid"
    execution_status = "job-status"
    representation_contents = "some\nrepresentation"
    mapping_contents = { 'foo' => 'bar' }

    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "submission_uuid" => submission_uuid,
        "execution_status" => execution_status,
        "execution_output" => {
          "representation.txt" => representation_contents,
          "mapping.json" => mapping_contents.to_json
        }
      }
    )

    Submission::Representation::Process.expects(:call).with(
      submission_uuid,
      execution_status,
      representation_contents,
      mapping_contents
    )

    ToolingJob::Process.(id)
  end

  test "proxies to analyzer" do
    id = SecureRandom.uuid
    type = "analyzer"
    submission_uuid = "submission-uuid"
    execution_status = "job-status"
    analysis = { 'some' => 'result' }

    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "submission_uuid" => submission_uuid,
        "execution_status" => execution_status,
        "execution_output" => { "analysis.json" => analysis.to_json }
      }
    )

    Submission::Analysis::Process.expects(:call).with(
      submission_uuid,
      execution_status,
      analysis
    )

    ToolingJob::Process.(id)
  end

  test "sets dynamodb job status to processed" do
    id = SecureRandom.uuid
    type = "analyzer"
    submission = create :submission
    execution_status = "job-status"
    analysis = { 'some' => 'result' }

    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "submission_uuid" => submission.uuid,
        "execution_status" => execution_status,
        "execution_output" => { "analysis.json" => analysis.to_json }
      }
    )

    ToolingJob::Process.(id)

    assert_equal "processed", ToolingJob.find(id).job_status
  end
end

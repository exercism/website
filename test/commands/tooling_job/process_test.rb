require 'test_helper'

class ToolingJob::ProcessTest < ActiveSupport::TestCase
  test "proxies to test run" do
    id = SecureRandom.uuid
    type = "test_runner"
    iteration_uuid = "iteration-uuid"
    execution_status = "job-status"
    results = { 'some' => 'result' }
    s3_key = "#{id}/results.json"

    upload_to_s3(
      Exercism.config.aws_tooling_jobs_bucket,
      s3_key,
      results.to_json
    )
    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "iteration_uuid" => iteration_uuid,
        "execution_status" => execution_status,
        "output" => { "results.json" => s3_key }
      }
    )

    Iteration::TestRun::Process.expects(:call).with(
      iteration_uuid,
      execution_status,
      "Nothing to report",
      results
    )

    ToolingJob::Process.(id)
  end

  test "proxies to representer" do
    id = SecureRandom.uuid
    type = "representer"
    iteration_uuid = "iteration-uuid"
    execution_status = "job-status"
    representation_contents = "some\nrepresentation"
    representation_s3_key = "#{id}/representation.txt"

    mapping_contents = { 'foo' => 'bar' }
    mapping_s3_key = "#{id}/mapping.json"

    upload_to_s3(
      Exercism.config.aws_tooling_jobs_bucket,
      representation_s3_key,
      representation_contents
    )
    upload_to_s3(
      Exercism.config.aws_tooling_jobs_bucket,
      mapping_s3_key,
      mapping_contents.to_json
    )
    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "iteration_uuid" => iteration_uuid,
        "execution_status" => execution_status,
        "output" => {
          "representation.txt" => representation_s3_key,
          "mapping.json" => mapping_s3_key
        }
      }
    )

    Iteration::Representation::Process.expects(:call).with(
      iteration_uuid,
      execution_status,
      "Nothing to report",
      representation_contents,
      mapping_contents
    )

    ToolingJob::Process.(id)
  end

  test "proxies to analyzer" do
    id = SecureRandom.uuid
    type = "analyzer"
    iteration_uuid = "iteration-uuid"
    execution_status = "job-status"
    analysis = { 'some' => 'result' }
    s3_key = "#{id}/analysis.json"

    upload_to_s3(
      Exercism.config.aws_tooling_jobs_bucket,
      s3_key,
      analysis.to_json
    )
    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "iteration_uuid" => iteration_uuid,
        "execution_status" => execution_status,
        "output" => { "analysis.json" => s3_key }
      }
    )

    Iteration::Analysis::Process.expects(:call).with(
      iteration_uuid,
      execution_status,
      "Nothing to report",
      analysis
    )

    ToolingJob::Process.(id)
  end

  test "sets dynamodb job status to processed" do
    id = SecureRandom.uuid
    type = "analyzer"
    iteration = create :iteration
    execution_status = "job-status"
    analysis = { 'some' => 'result' }
    s3_key = "#{id}/analysis.json"

    upload_to_s3(
      Exercism.config.aws_tooling_jobs_bucket,
      s3_key,
      analysis.to_json
    )
    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "iteration_uuid" => iteration.uuid,
        "execution_status" => execution_status,
        "output" => { "analysis.json" => s3_key }
      }
    )

    ToolingJob::Process.(id)

    attrs = read_from_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      { id: id },
      %i[job_status]
    )
    assert_equal "processed", attrs["job_status"]
  end
end

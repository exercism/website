require 'test_helper'

class ToolingJob::ProcessTest < ActiveSupport::TestCase
  test "proxies to test run" do
    id = SecureRandom.uuid
    type = "test_runner"
    iteration_uuid = "iteration-uuid"
    execution_status = "job-status"
    result = { 'some' => 'result' }

    item = {
      "type" => type,
      "iteration_uuid" => iteration_uuid,
      "execution_status" => execution_status,
      "result" => result
    }

    Iteration::TestRun::Process.expects(:call).with(
      iteration_uuid,
      execution_status,
      "Nothing to report",
      result
    )

    # TODO: Create some factory methods for this
    # and test via the db rather than mocks
    client = mock
    ExercismConfig::SetupDynamoDBClient.expects(:call).returns(client)
    client.expects(:get_item).with(
      table_name: Exercism.config.dynamodb_tooling_jobs_table,
      key: { id: id },
      attributes_to_get: %i[
        type
        iteration_uuid
        execution_status
        result
      ]
    ).returns(mock(item: item))

    ToolingJob::Process.(id)
  end
end

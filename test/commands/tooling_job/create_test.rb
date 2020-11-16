require 'test_helper'

class ToolingJob::CreateTest < ActiveSupport::TestCase
  test "proxies to dynamodb" do
    freeze_time do
      type = "foobars"
      uuid = SecureRandom.uuid
      SecureRandom.expects(:uuid).returns(uuid)

      # TODO: Test via the db rather than mocks
      client = mock
      ExercismConfig::SetupDynamoDBClient.expects(:call).returns(client)
      client.expects(:put_item).with(
        table_name: Exercism.config.dynamodb_tooling_jobs_table,
        item: {
          id: uuid,
          created_at: Time.current.utc.to_i,
          type: type,
          job_status: :queued,
          foo: :bar
        }
      )

      ToolingJob::Create.(SecureRandom.uuid, type, { foo: :bar })
    end
  end
end

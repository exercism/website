module ToolingJob
  class Create
    include Mandate

    initialize_with :type, :attributes

    def call
      client.put_item(
        table_name: Exercism.config.dynamodb_tooling_jobs_table,
        item: attributes.merge(
          id: SecureRandom.uuid,
          created_at: Time.current.utc.to_i,
          type: type,
          job_status: :pending
        )
      )
    end

    def client
      ExercismConfig::SetupDynamoDBClient.()
    end
  end
end

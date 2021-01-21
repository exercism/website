class ToolingJob
  class Create
    include Mandate

    initialize_with :type, :attributes

    def call
      Exercism.dynamodb_client.put_item(
        table_name: Exercism.config.dynamodb_tooling_jobs_table,
        item: attributes.merge(
          id: SecureRandom.uuid,
          created_at: Time.current.utc.to_i,
          type: type,
          job_status: :queued
        )
      )
    end
  end
end

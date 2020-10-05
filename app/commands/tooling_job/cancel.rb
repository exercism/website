module ToolingJob
  class Cancel
    include Mandate

    initialize_with :iteration_uuid, :type

    def call
      client.update_item(
        table_name: Exercism.config.dynamodb_tooling_jobs_table,
        key: {
          type: type,
          iteration_uuid: iteration_uuid
        },
        expression_attribute_names: {
          "#JS": "job_status",
          "#LU": "locked_until"
        },
        expression_attribute_values: {
          ":js": "cancelled",
          ":lu": nil
        },
        update_expression: "SET #JS = :js, #LU = :lu"
      )
    end

    memoize
    def client
      ExercismConfig::SetupDynamoDBClient.()
    end
  end
end

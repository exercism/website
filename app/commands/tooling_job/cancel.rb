module ToolingJob
  class Cancel
    include Mandate

    initialize_with :iteration_uuid

    def call
      iteration = Iteration.find_by!(uuid: iteration_uuid)
      iteration.analysis_cancelled!
      iteration.representation_cancelled!
      cancel_job(:analyzer)
      cancel_job(:representer)
    end

    private
    attr_reader :iteration_uuid, :type

    def client
      ExercismConfig::SetupDynamoDBClient.()
    end

    def cancel_job(type)
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
  end
end

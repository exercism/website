module ToolingJob
  class Cancel
    include Mandate

    initialize_with :iteration_uuid, :type

    def call
      iteration = Iteration.find_by!(uuid: iteration_uuid)

      items = client.query({
                             table_name: Exercism.config.dynamodb_tooling_jobs_table,
                             index_name: "iteration_type",
                             expression_attribute_values: {
                               ":IU" => iteration_uuid,
                               ":TP" => type,
                               ":JS" => :pending
                             },
                             expression_attribute_names: {
                               "#IU": "iteration_uuid",
                               "#TP": "type",
                               "#ID": "id",
                               "#JS": "job_status"
                             },
                             key_condition_expression: "#IU = :IU AND #TP = :TP",
                             filter_expression: "#JS = :JS",
                             projection_expression: "#ID"
                           }).items

      if items.length.positive?
        id = items[0]["id"]

        client.update_item(
          table_name: Exercism.config.dynamodb_tooling_jobs_table,
          key: {
            id: id
          },
          expression_attribute_names: {
            "#JS": "job_status"
          },
          expression_attribute_values: {
            ":js": "cancelled"
          },
          update_expression: "SET #JS = :js"
        )
      end

      case type
      when :test_runner
        iteration.tests_cancelled!
      when :representer
        iteration.representation_cancelled!
      when :analyzer
        iteration.analysis_cancelled!
      end
    end

    memoize
    def client
      ExercismConfig::SetupDynamoDBClient.()
    end
  end
end

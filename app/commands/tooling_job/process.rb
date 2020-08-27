module ToolingJob
  class Process
    include Mandate

    initialize_with :id

    def call
      attrs = client.get_item(
        table_name: Exercism.config.dynamodb_tooling_jobs_table,
        key: { id: id },
        attributes_to_get: %i[
          type
          iteration_uuid
          execution_status
          result
        ]
      ).item

      case attrs['type']
      when "test_runner"
        Iteration::TestRun::Process.(
          attrs["iteration_uuid"],
          attrs["execution_status"],
          "Nothing to report", # TODO
          attrs["result"]
        )
      when "representer"
        Iteration::Representation::Process.(
          attrs["iteration_uuid"],
          attrs["execution_status"],
          "Nothing to report", # TODO
          attrs["result"]
        )
      when "analyzer"
        Iteration::Analysis::Process.(
          attrs["iteration_uuid"],
          attrs["execution_status"],
          "Nothing to report", # TODO
          attrs["result"]
        )
      end
    end

    memoize
    def client
      ExercismConfig::SetupDynamoDBClient.()
    end
  end
end

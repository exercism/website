module ToolingJob
  class Cancel
    include Mandate

    initialize_with :submission_uuid, :type

    def call
      return unless queued_dynamodb_job

      update_dynamodb
      update_submission
    end

    private
    memoize
    def queued_dynamodb_job
      client.query(
        {
          table_name: Exercism.config.dynamodb_tooling_jobs_table,
          index_name: "submission_type",
          expression_attribute_values: {
            ":SU" => submission_uuid,
            ":TP" => type,
            ":JS" => :queued
          },
          expression_attribute_names: {
            "#SU": "submission_uuid",
            "#TP": "type",
            "#ID": "id",
            "#JS": "job_status"
          },
          key_condition_expression: "#SU = :SU AND #TP = :TP",
          filter_expression: "#JS = :JS",
          projection_expression: "#ID"
        }
      ).items.first
    end

    def update_dynamodb
      client.update_item(
        table_name: Exercism.config.dynamodb_tooling_jobs_table,
        key: {
          id: queued_dynamodb_job["id"]
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

    def update_submission
      submission = Submission.find_by!(uuid: submission_uuid)

      case type
      when :test_runner
        submission.tests_cancelled!
      when :representer
        submission.representation_cancelled!
      when :analyzer
        submission.analysis_cancelled!
      end
    end

    memoize
    def client
      ExercismConfig::SetupDynamoDBClient.()
    end
  end
end

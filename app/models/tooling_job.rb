class ToolingJob
  def self.create!(type, attributes)
    client = Exercism.config.dynamodb_client
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

  def self.process!(id)
    client = Exercism.config.dynamodb_client
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
        "Nothing to report", # TOOD
        attrs["result"]
      )
    end
  end
end

#     # We use update_item in case the job processor writes
#     # first, so that we don't override its attributes
#
#     # This complex syntax becomes clearer when reading the docs:
#     # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html#update_item-instance_method
#     attr_names = { "#I" => "iteration_uuid" }
#     attr_values = { ":i" => iteration_uuid }
#     attributes.each.with_index do |(k, v), idx|
#       attr_names["#A#{idx}"] = k
#       attr_values[":a#{idx}"] = v
#     end
#
#     update_expression = attr_names.zip(attr_values).map do |name, value|
#       "#{name[0]}=#{value[0]}"
#     end.join(', ')
#
#     client = Exercism.config.dynamodb_client
#     client.update_item(
#       table_name: :tooling_jobs,
#
#       key: { id: id, type: type },
#       expression_attribute_names: attr_names,
#       expression_attribute_values: attr_values,
#       update_expression: "SET #{update_expression}"
#     )
#   end
# end

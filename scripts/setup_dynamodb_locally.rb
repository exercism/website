%w[tooling_jobs tooling_jobs-test].each do |table_name|
  begin
    Exercism.config.dynamodb_client.delete_table(
      table_name: table_name,
    )
  rescue Aws::DynamoDB::Errors::ResourceNotFoundException
  end

  Exercism.config.dynamodb_client.create_table(
    table_name: table_name,
    attribute_definitions: [
      {
        attribute_name: "id", 
        attribute_type: "S", 
      },
    ],
    key_schema: [
      {
        attribute_name: "id", 
        key_type: "HASH", 
      }
    ],
    provisioned_throughput: {
      read_capacity_units: 1, 
      write_capacity_units: 1, 
    }, 
  )

  Exercism.config.dynamodb_client.update_table(
    table_name: table_name,
    attribute_definitions: [
      {
        attribute_name: "job_status", 
        attribute_type: "S", 
      }, 
      {
        attribute_name: "created_at",
        attribute_type: "N",
      },
    ],
    global_secondary_index_updates: [
      {
        create: {
          index_name: "job_status", # required
          key_schema: [ # required
            {
              attribute_name: "job_status", # required
              key_type: "HASH", # required, accepts HASH, RANGE
            },
            {
              attribute_name: "created_at", # required
              key_type: "RANGE", # required, accepts HASH, RANGE
            },
          ],
          projection: { # required
            projection_type: "KEYS_ONLY",
          },
          provisioned_throughput: {
            read_capacity_units: 1, # required
            write_capacity_units: 1, # required
          }
        }
      },
    ],
  )
end

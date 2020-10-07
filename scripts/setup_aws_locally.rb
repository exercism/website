# Only allow this to run in development
return unless Rails.env.development?

##################
# Setup local s3 #
##################

# We don't need this running for CI atm as none of our 
# tests actually hit s3. Although we might choose to change this
unless ENV["EXERCISM_CI"]
  ExercismConfig::SetupS3Client.().create_bucket(bucket: Exercism.config.aws_submissions_bucket)
end

########################
# Setup local dynamodb #
########################
%w[tooling_jobs tooling_jobs-test].each do |table_name|
  begin
    ExercismConfig::SetupDynamoDBClient.().delete_table(
      table_name: table_name
    )
  rescue Aws::DynamoDB::Errors::ResourceNotFoundException
  end

  ExercismConfig::SetupDynamoDBClient.().create_table(
    table_name: table_name,
    attribute_definitions: [
      {
        attribute_name: "id",
        attribute_type: "S"
      }
    ],
    key_schema: [
      {
        attribute_name: "id",
        key_type: "HASH"
      }
    ],
    provisioned_throughput: {
      read_capacity_units: 1,
      write_capacity_units: 1
    }
  )

  ExercismConfig::SetupDynamoDBClient.().update_table(
    table_name: table_name,
    attribute_definitions: [
      {
        attribute_name: "job_status",
        attribute_type: "S"
      },
      {
        attribute_name: "created_at",
        attribute_type: "N"
      }
    ],
    global_secondary_index_updates: [
      {
        create: {
          index_name: "job_status", # required
          key_schema: [ # required
            {
              attribute_name: "job_status", # required
              key_type: "HASH" # required, accepts HASH, RANGE
            },
            {
              attribute_name: "created_at", # required
              key_type: "RANGE" # required, accepts HASH, RANGE
            }
          ],
          projection: { # required
            projection_type: "KEYS_ONLY"
          },
          provisioned_throughput: {
            read_capacity_units: 1, # required
            write_capacity_units: 1 # required
          }
        }
      }
    ]
  )

  ExercismConfig::SetupDynamoDBClient.().update_table(
    table_name: table_name,
    attribute_definitions: [
      {
        attribute_name: "iteration_uuid",
        attribute_type: "S"
      },
      {
        attribute_name: "type",
        attribute_type: "S"
      }
    ],
    global_secondary_index_updates: [
      {
        create: {
          index_name: "iteration_type", # required
          key_schema: [ # required
            {
              attribute_name: "iteration_uuid", # required
              key_type: "HASH" # required, accepts HASH, RANGE
            },
            {
              attribute_name: "type", # required
              key_type: "RANGE" # required, accepts HASH, RANGE
            }
          ],
          projection: { # required
            projection_type: "INCLUDE",
            non_key_attributes: ["id", "job_status"]
          },
          provisioned_throughput: {
            read_capacity_units: 1, # required
            write_capacity_units: 1 # required
          }
        }
      }
    ]
  )
end

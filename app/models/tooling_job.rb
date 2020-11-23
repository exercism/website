class ToolingJob
  extend Mandate::Memoize
  BASIC_ATTRIBUTES = %i[
    id
    submission_uuid
    type
    job_status
  ].freeze

  def self.find(id, full: false)
    params = {
      table_name: dynamodb_table_name,
      key: { id: id }
    }
    params[:attributes_to_get] = BASIC_ATTRIBUTES unless full

    new(dynamodb_client.get_item(params).item)
  end

  def self.find_queued(submission_uuid, type)
    item = dynamodb_client.query(
      table_name: dynamodb_table_name,
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
    ).items.first
    new(item)
  end

  attr_reader :id, :submission_uuid, :type, :job_status, :created_at
  attr_reader :language, :exercise, :locked_until
  attr_reader :execution_status, :execution_metadata, :execution_output

  def initialize(params)
    params.each { |key, value| send("#{key}=", value) }
  end

  def processed!
    dynamodb_client.update_item(
      table_name: dynamodb_table_name,
      key: { id: id },
      expression_attribute_names: { "#JS": "job_status" },
      expression_attribute_values: { ":js": "processed" },
      update_expression: "SET #JS = :js"
    )
  end

  def cancelled!
    dynamodb_client.update_item(
      table_name: dynamodb_table_name,
      key: { id: id },
      expression_attribute_names: { "#JS": "job_status" },
      expression_attribute_values: { ":js": "cancelled" },
      update_expression: "SET #JS = :js"
    )
  end

  def ==(other)
    id == other.id
  end

  def stderr
    read_s3_file('stderr')
  end

  def stdout
    read_s3_file('stdout')
  end

  def read_s3_file(name)
    s3_client.get_object(
      bucket: s3_bucket_name,
      key: "#{s3_folder}/#{name}"
    ).body.read
  rescue StandardError
    ""
  end

  memoize
  def self.dynamodb_client
    ExercismConfig::SetupDynamoDBClient.()
  end

  memoize
  def self.dynamodb_table_name
    Exercism.config.dynamodb_tooling_jobs_table
  end

  memoize
  def self.s3_client
    ExercismConfig::SetupS3Client.()
  end

  memoize
  def s3_folder
    "#{Exercism.env}/#{id}"
  end

  memoize
  def s3_bucket_name
    Exercism.config.aws_tooling_jobs_bucket
  end

  delegate :dynamodb_client, :s3_client, :dynamodb_table_name, to: self

  private
  attr_writer :id, :submission_uuid, :type, :job_status, :created_at
  attr_writer :language, :exercise, :locked_until
  attr_writer :execution_status, :execution_metadata, :execution_output
  attr_writer :s3_uri
end

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
      table_name: table_name,
      key: { id: id }
    }
    params[:attributes_to_get] = BASIC_ATTRIBUTES unless full

    new(client.get_item(params).item)
  end

  def self.find_queued(submission_uuid, type)
    item = client.query(
      table_name: table_name,
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
  attr_reader :s3_uri

  def initialize(params)
    params.each { |key, value| send("#{key}=", value) }
  end

  def processed!
    client.update_item(
      table_name: table_name,
      key: { id: id },
      expression_attribute_names: { "#JS": "job_status" },
      expression_attribute_values: { ":js": "processed" },
      update_expression: "SET #JS = :js"
    )
  end

  def cancelled!
    client.update_item(
      table_name: Exercism.config.dynamodb_tooling_jobs_table,
      key: { id: id },
      expression_attribute_names: { "#JS": "job_status" },
      expression_attribute_values: { ":js": "cancelled" },
      update_expression: "SET #JS = :js"
    )
  end

  def ==(other)
    id == other.id
  end

  def self.client
    ExercismConfig::SetupDynamoDBClient.()
  end

  def self.table_name
    Exercism.config.dynamodb_tooling_jobs_table
  end
  delegate :client, :table_name, to: self

  private
  attr_writer :id, :submission_uuid, :type, :job_status, :created_at
  attr_writer :language, :exercise, :locked_until
  attr_writer :execution_status, :execution_metadata, :execution_output
  attr_writer :s3_uri
end

class SerializeSubmissionTestRun
  include Mandate

  initialize_with :test_run

  def call
    return unless test_run

    {
      id: test_run.id,
      submission_uuid: test_run.submission.uuid,
      status: status,
      message: message,
      tests: test_run.test_results
    }
  end

  private
  def status
    return OPS_ERROR_STATUS unless test_run.ops_success?
    return :error unless VALID_STATUSES.include?(test_run.status)

    test_run.status
  end

  def message
    return test_run.message if test_run.message.present?
    return nil if test_run.ops_success?

    # TODO: Decide how this is corrolated with the
    # errors upstream and move into i18n.
    "Some error occurred"
  end

  OPS_ERROR_STATUS = "ops_error".freeze
  private_constant :OPS_ERROR_STATUS

  VALID_STATUSES = %i[pass fail error].freeze
  private_constant :VALID_STATUSES
end

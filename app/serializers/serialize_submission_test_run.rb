class SerializeSubmissionTestRun
  include Mandate

  initialize_with :test_run

  def call
    return unless test_run

    {
      id: test_run.id,
      submission_uuid: test_run.submission.uuid,
      version: test_run.version,
      status: status,
      message: message,
      message_html: message_html,
      output: test_run.output,
      output_html: output_html,
      tests: test_run.test_results,
      links: {
        self: Exercism::Routes.api_solution_submission_test_run_url(test_run.solution.uuid, test_run.submission.uuid)
      }
    }
  end

  private
  def status
    return OPS_ERROR_STATUS unless test_run.ops_success?
    return :error unless VALID_STATUSES.include?(test_run.status)

    test_run.status
  end

  def message_html
    return nil unless message

    sanitized_message = message.gsub("\e\[K", '')
    Ansi::To::Html.new(sanitized_message).to_html
  end

  memoize
  def message
    return "An unknown error occurred" if !test_run.ops_success? && test_run.message.blank?

    test_run.message
  end

  def output_html
    return if test_run.output.blank?

    # The ansi-to-html library does not support unicode escape sequence
    # See https://github.com/rburns/ansi-to-html/issues/48
    sanitized_output = test_run.output.gsub("\e\[K", '')
    Ansi::To::Html.new(sanitized_output).to_html
  end

  OPS_ERROR_STATUS = "ops_error".freeze
  private_constant :OPS_ERROR_STATUS

  VALID_STATUSES = %i[pass fail error].freeze
  private_constant :VALID_STATUSES
end

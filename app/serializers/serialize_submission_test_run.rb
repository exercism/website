class SerializeSubmissionTestRun
  include Mandate

  initialize_with :test_run

  def call
    return unless test_run

    {
      uuid: test_run.uuid,
      submission_uuid: test_run.submission.uuid,
      version: test_run.version,
      status:,
      message:,
      message_html: Ansi::RenderHTML.(message),
      output: test_run.output,
      output_html: Ansi::RenderHTML.(test_run.output),
      tests: test_run.test_results,
      tasks:,
      highlightjs_language: test_run.solution.track.highlightjs_language,
      links: {
        self: Exercism::Routes.api_solution_submission_test_run_url(test_run.solution.uuid, test_run.submission.uuid)
      }
    }
  end

  private
  def status
    return TIMEOUT_STATUS if test_run.timed_out?
    return OPS_ERROR_STATUS unless test_run.ops_success?
    return :error unless VALID_STATUSES.include?(test_run.status)

    test_run.status
  end

  memoize
  def message
    return "An unknown error occurred" if !test_run.ops_success? && test_run.message.blank?

    test_run.message
  end

  def tasks
    return [] unless test_run.version >= 3

    SerializeExerciseAssignment.(test_run.solution)[:tasks].to_a.map { |task| task.slice(:id, :title) }
  end

  OPS_ERROR_STATUS = "ops_error".freeze
  TIMEOUT_STATUS = "timeout".freeze
  private_constant :OPS_ERROR_STATUS, :TIMEOUT_STATUS

  VALID_STATUSES = %i[pass fail error].freeze
  private_constant :VALID_STATUSES
end

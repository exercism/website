class Submission::Representation::Generate
  include Mandate

  queue_as :solution_processing

  initialize_with :submission, :git_sha, reason: nil, retries_count: 0

  MAX_RETRIES = 3

  # The representer refuses solutions larger than this, so we don't call it for them.
  MAX_SOLUTION_SIZE = 200.kilobytes

  RepresenterTemporarilyUnavailable = Class.new(StandardError)

  def call
    return handle_unrepresentable! unless representable?

    # The representer returns no representation, along with a reason,
    # if it can't parse the solution or the solution is too deep or large.
    return handle_unrepresentable! if representation.nil?

    process_results!(200, representation, mapping, response.fetch("version"))
  rescue RestClient::BadGateway, RestClient::ServiceUnavailable, RestClient::GatewayTimeout,
         RestClient::Exceptions::Timeout => e
    retry_later!(e.http_code)
  rescue RestClient::ExceptionWithResponse => e
    # Any other error status means that we sent a request that the
    # representer can't handle, so retrying won't help.
    Sentry.capture_exception(e)
    handle_ops_error!(e.http_code)
  end

  # Reruns of a whole exercise or track can queue thousands of jobs.
  # This runs them on the background queue so that they don't hold
  # up the representations of new submissions.
  class InBackground < self
    queue_as :background
  end

  private
  def representable?
    solution_files.present? && solution_files.values.sum(&:bytesize) <= MAX_SOLUTION_SIZE
  end

  def handle_unrepresentable!
    return if reason == :update

    submission.representation_unrepresentable!
    submission.broadcast!
    submission.iteration&.broadcast!
  end

  def retry_later!(ops_status)
    if retries_count >= MAX_RETRIES
      handle_ops_error!(ops_status)

      # This error is manually ignored on Sentry unless it escalates
      raise RepresenterTemporarilyUnavailable
    end

    self.class.defer(submission, git_sha, reason:, retries_count: retries_count + 1, wait: rand(30..90))
  end

  def handle_ops_error!(ops_status)
    # A rerun for an update doesn't touch the submission, so there's nothing to record.
    return if reason == :update

    process_results!(ops_status, nil, {}, nil)
  end

  def process_results!(ops_status, ast, mapping, representer_version)
    Submission::Representation::ProcessResults.(
      submission, git_sha,
      reason,
      tooling_job_id, ops_status,
      ast, Submission::Representation.digest_ast(ast), mapping,
      representer_version, exercise_repo.representer_version
    )
  end

  memoize
  def response
    body = RestClient.post(
      Exercism.config.representer_url,
      {
        track_slug: submission.track.slug,
        exercise_slug: submission.exercise.slug,
        solution_files:,
        exercise_files:
      }.to_json,
      { content_type: :json, accept: :json }
    ).body

    JSON.parse(body)
  end

  def representation = response["representation"]

  def mapping
    res = response["mapping"]
    res.is_a?(Hash) ? res.symbolize_keys : {}
  end

  memoize
  def solution_files
    submission.valid_files(exercise_repo).to_h { |file| [file.filename, file.content] }
  end

  # The representer uses these to find the names that the tests rely on.
  memoize
  def exercise_files
    filepaths = [
      ".meta/config.json",
      *exercise_repo.test_filepaths,
      *exercise_repo.editor_filepaths,
      *exercise_repo.solution_filepaths
    ].uniq

    filepaths.index_with { |filepath| exercise_repo.read_file_blob(filepath) }.compact
  end

  memoize
  def exercise_repo = Git::Exercise.for_solution(submission.solution, git_sha:)

  memoize
  def tooling_job_id = "lambda-#{SecureRandom.compact_uuid}"
end

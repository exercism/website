class Submission::Create
  include Mandate

  def initialize(solution, raw_files, submitted_via, test_results_json = nil)
    @submission_uuid = SecureRandom.compact_uuid
    @solution = solution
    @submitted_via = submitted_via
    @test_results_json = test_results_json

    # TODO: (Optional) - Move this into another service
    # TODO: (Optional) - Consider risks around filenames
    @submitted_files = raw_files.each do |f|
      f[:digest] = Digest::SHA1.hexdigest(f[:content])
    end
  end

  def call
    # This needs to be fast.
    guard!

    create_submission!
    create_files!
    handle_test_run!
    schedule_jobs!
    log_metric!

    # End by returning the new submission
    submission
  end

  private
  attr_reader :solution, :submitted_files, :submission_uuid, :submitted_via, :submission, :test_results_json

  delegate :track, :user, to: :solution

  # In this guard we check the last submission that wasn't
  # cancelled or exceptioned.
  def guard!
    last_submission = solution.latest_valid_submission
    return unless last_submission

    prev_files = last_submission.files.map { |f| "#{f.filename}|#{f.digest}" }
    new_files = submitted_files.map { |f| "#{f[:filename]}|#{f[:digest]}" }

    raise DuplicateSubmissionError if prev_files.sort == new_files.sort
  end

  def create_submission!
    @submission = solution.submissions.create!(
      uuid: submission_uuid,
      submitted_via:
    )
  end

  def create_files!
    submitted_files.each do |file|
      submission.files.create!(
        file.slice(:uuid, :filename, :digest, :content)
      )
    end
  end

  def handle_test_run!
    if test_results_json
      Submission::TestRun::Process.(FauxToolingJob.new(submission, test_results_json))
    else
      Submission::TestRun::Init.(submission)
    end
  end

  def schedule_jobs!
    AwardBadgeJob.perform_later(solution.user, :rookie)
  end

  def log_metric!
    Metric::Queue.(:submit_submission, submission.created_at, submission:, track:, user:)
  end

  # Rather than rewrite this critical component, for now
  # we're just stubbing a tooling job as if it had come back
  # from the server.
  class FauxToolingJob
    include Mandate

    initialize_with :submission, :test_results_json do
      @id = SecureRandom.uuid
    end

    attr_reader :id

    delegate :uuid, to: :submission, prefix: true
    def execution_status = 200
    def source = { "exercise_git_sha" => submission.solution.git_sha }
    def execution_output = { "results.json" => test_results_json }
  end
end

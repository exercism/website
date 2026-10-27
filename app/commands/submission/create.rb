class Submission::Create
  include Mandate

  def initialize(solution, raw_files, submitted_via, test_results_json = nil)
    @submission_uuid = SecureRandom.compact_uuid
    @solution = solution
    @submitted_via = submitted_via
    @test_results_json = test_results_json

    # TODO: (Optional) - Move this into another service
    @submitted_files = raw_files.each do |f|
      f[:digest] = Digest::SHA1.hexdigest(f[:content])
    end
  end

  def call
    # This needs to be fast.
    validate_filenames!
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

  def validate_filenames!
    raise InvalidSubmissionFilenameError unless submitted_files.all? { |f| valid_filename?(f[:filename]) }
  end

  # Filenames must be relative paths made up of named segments
  def valid_filename?(filename)
    return false unless filename.is_a?(String)
    return false if filename.empty?
    return false if filename.start_with?("/")
    return false if filename.include?("\0") || filename.include?("\\")

    filename.split("/", -1).none? { |segment| segment.empty? || segment == ".." }
  end

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
    if test_results_json.present?
      Submission::TestRun::ProcessClientSideResults.(submission, test_results_json)
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
end

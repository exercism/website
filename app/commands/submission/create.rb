class Submission::Create
  include Mandate

  def initialize(solution, files, submitted_via)
    @submission_uuid = SecureRandom.compact_uuid

    @solution = solution
    @submitted_files = files
    @submitted_via = submitted_via

    # TODO: (Optional) - Move this into another service
    # TODO: (Optional) - Consider risks around filenames
    @submitted_files.each do |f|
      f[:digest] = Digest::SHA1.hexdigest(f[:content])
    end
  end

  def call
    # This needs to be fast.
    guard!

    create_submission!
    create_files!
    init_test_run!
    schedule_jobs!
    log_metric!

    # End by returning the new submission
    submission
  end

  private
  attr_reader :solution, :submitted_files, :submission_uuid, :submitted_via, :submission

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

  def init_test_run!
    Submission::TestRun::Init.(submission)
  end

  def schedule_jobs!
    AwardBadgeJob.perform_later(solution.user, :rookie)
  end

  def log_metric!
    Metric::Queue.(:submit_submission, submission.created_at, submission:, track:, user:)
  end
end

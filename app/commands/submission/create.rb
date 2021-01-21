class Submission
  class Create
    include Mandate

    def initialize(solution, files, submitted_via)
      @submission_uuid = SecureRandom.compact_uuid

      @solution = solution
      @submitted_files = files
      @submitted_via = submitted_via

      # TODO: - Move this into another service
      # and that service should also guard filenames
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
      submission.broadcast!

      # End by returning the new submission
      submission
    end

    private
    attr_reader :solution, :submitted_files, :submission_uuid, :submitted_via, :submission

    def guard!
      last_submission = solution.submissions.last
      return unless last_submission

      prev_files = last_submission.files.map { |f| "#{f.filename}|#{f.digest}" }
      new_files = submitted_files.map { |f| "#{f[:filename]}|#{f[:digest]}" }

      raise DuplicateSubmissionError if prev_files.sort == new_files.sort
    end

    def create_submission!
      @submission = solution.submissions.create!(
        uuid: submission_uuid,
        submitted_via: submitted_via,
        tests_status: :queued
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
  end
end

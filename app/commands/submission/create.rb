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

      # Kick off the threads to get things uploaded
      # before we do anything with the database.

      # These thread must *not* touch the DB or have any
      # db models passed to them.
      services_thread = Thread.new { init_services }

      create_submission!
      create_files!
      schedule_jobs!
      submission.broadcast!

      # Finally wait for everyhting to finish before
      # we return the submission.
      services_thread.join

      # End by returning the new submission
      submission
    end

    private
    attr_reader :solution, :submitted_files, :submission_uuid, :submitted_via
    attr_reader :submission

    def guard!
      last_submission = solution.submissions.last
      return unless last_submission

      prev_files = last_submission.files.map { |f| "#{f.filename}|#{f.digest}" }
      new_files = submitted_files.map { |f| "#{f[:filename]}|#{f[:digest]}" }

      raise DuplicateSubmissionError if prev_files.sort == new_files.sort
    end

    # TODO: Simply this once the analyse code has
    # moved to iterations service.
    def init_services
      # Let's get it up first, then we'll fan out to
      # all the services we want to run this,
      s3_uri = Submission::UploadWithExercise.(
        submission_uuid,
        submitted_files,
        exercise_files,
        solution.track.test_regexp
      )

      jobs = []
      jobs << [
        Thread.new do
          Submission::TestRun::Init.(submission_uuid, solution.track.slug, solution.exercise.slug, s3_uri)
        end
      ]
      # TODO: Move to iteration create
      # jobs += [
      #   Thread.new do
      #     Submission::Analysis::Init.(submission_uuid, solution.track.slug, solution.exercise.slug, s3_uri)
      #   end,
      #   Thread.new do
      #     Submission::Representation::Init.(submission_uuid, solution.track.slug, solution.exercise.slug, s3_uri)
      #   end
      # ]

      jobs.each(&:join)
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

    def schedule_jobs!
      AwardBadgeJob.perform_later(solution.user, :rookie)
    end

    memoize
    def exercise_files
      Git::Exercise.for_solution(solution).non_ignored_files
    end
  end
end

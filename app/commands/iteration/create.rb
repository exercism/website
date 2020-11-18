class Iteration
  class Create
    include Mandate

    initialize_with :solution, :submission

    def call
      id = Iteration.connection.insert(%{
        INSERT INTO iterations (uuid, solution_id, submission_id, idx, created_at, updated_at)
        SELECT "#{SecureRandom.compact_uuid}", #{solution.id}, #{submission.id}, (COUNT(*) + 1), NOW(), NOW()
        FROM iterations where solution_id = #{solution.id}
      })
      Iteration.find(id).tap do |iteration|
        init_services(iteration)
        record_activity!(iteration)
      end
    rescue ActiveRecord::RecordNotUnique
      Iteration.find_by!(solution: solution, submission: submission)
    end

    # TODO: All this is very messy
    def init_services(_iteration)
      submission_uuid = submission.uuid
      submission_files = submission.files.map do |file|
        { filename: file.filename, content: file.content }
      end

      test_regexp = solution.track.test_regexp
      track_slug = solution.track.slug
      exercise_slug = solution.exercise.slug

      # Important: Ensure there is no DB access within the threads.
      # Can we enforce this somehow?
      [
        Thread.new do
          job_id = SecureRandom.uuid
          ToolingJob::UploadFiles.(job_id, submission_files, [], test_regexp)
          Submission::Representation::Init.(job_id, submission_uuid, track_slug, exercise_slug)
        end,
        Thread.new do
          job_id = SecureRandom.uuid
          ToolingJob::UploadFiles.(job_id, submission_files, [], test_regexp)
          Submission::Analysis::Init.(job_id, submission_uuid, track_slug, exercise_slug)
        end
      ].each(&:join)
    end

    def record_activity!(iteration)
      User::Activity::Create.(
        :submitted_iteration,
        solution.user,
        track: solution.track,
        exercise: solution.exercise,
        iteration: iteration
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end
  end
end

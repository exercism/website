class Iteration
  class Create
    include Mandate

    initialize_with :solution, :submission

    def call
      time = Time.now.utc.to_s(:db)
      id = Iteration.connection.insert(%{
        INSERT INTO iterations (uuid, solution_id, submission_id, idx, created_at, updated_at)
        SELECT "#{SecureRandom.compact_uuid}", #{solution.id}, #{submission.id}, (COUNT(*) + 1), "#{time}", "#{time}"
        FROM iterations where solution_id = #{solution.id}
      })
      Iteration.find(id).tap do |iteration|
        init_services
        record_activity!(iteration)
      end
    rescue ActiveRecord::RecordNotUnique
      Iteration.find_by!(solution: solution, submission: submission)
    end

    def init_services
      Submission::Representation::Init.(submission)
      # Submission::Analysis::Init.(submission)
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

class Iteration
  class Create
    include Mandate

    initialize_with :solution, :submission

    def call
      time = Time.now.utc.to_formatted_s(:db)
      id = Iteration.connection.insert(%{
        INSERT INTO iterations (uuid, solution_id, submission_id, idx, created_at, updated_at)
        SELECT "#{SecureRandom.compact_uuid}", #{solution.id}, #{submission.id}, (COUNT(*) + 1), "#{time}", "#{time}"
        FROM iterations where solution_id = #{solution.id}
      })

      Iteration.find(id).tap do |iteration|
        iteration.handle_after_save!
        init_services

        solution.update_status!
        solution.update_iteration_status!
        solution.update(unlocked_help: true)
        Solution.reset_counters(solution.id, :iterations)

        GenerateIterationSnippetJob.perform_later(iteration)
        CalculateLinesOfCodeJob.perform_later(iteration)
        ProcessIterationForDiscussionsJob.perform_later(iteration)
        AwardBadgeJob.perform_later(user, :die_unendliche_geschichte, context: iteration)
        AwardBadgeJob.perform_later(user, :growth_mindset)
        record_activity!(iteration)
        log_metric!(iteration)
      end
    rescue ActiveRecord::RecordNotUnique
      Iteration.find_by!(solution:, submission:)
    end

    def init_services
      Submission::TestRun::Init.(submission) if submission.tests_not_queued? && solution.exercise.has_test_runner?
      Submission::Representation::Init.(submission) if solution.track.has_representer?
      Submission::Analysis::Init.(submission) if solution.track.has_analyzer?
    end

    def record_activity!(iteration)
      User::Activity::Create.(
        :submitted_iteration,
        user,
        track: solution.track,
        solution:,
        iteration:
      )
      # rescue StandardError => e
      #   Rails.logger.error "Failed to create activity"
      #   Rails.logger.error e.message
    end

    def log_metric!(iteration)
      Metric::Queue.(:submit_iteration, iteration.created_at, iteration:, track:, user:)
    end

    delegate :track, :user, to: :solution
  end
end

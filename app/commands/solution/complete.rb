class Solution
  class Complete
    include Mandate

    initialize_with :solution, :user_track

    def call
      raise SolutionHasNoIterationsError if solution.iterations.empty?

      solution.with_lock do
        return if solution.completed?

        solution.update!(completed_at: Time.current)
      end

      # TODO: Think about how we can add a guard here for hello-world so
      # we only go through the checks in the job if the exercise is hello-world.
      # But at the job level, not at this level. So passing some args etc?
      AwardBadgeJob.perform_later(user, :anybody_there)
      AwardBadgeJob.perform_later(user, :all_your_base)
      record_activity!
    end

    private
    def record_activity!
      User::Activity::Create.(
        :completed_exercise,
        user,
        track: exercise.track,
        solution: solution
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end

    memoize
    def user
      solution.user
    end

    memoize
    def exercise
      solution.exercise
    end
  end
end

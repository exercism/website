class Solution
  class Complete
    include Mandate

    initialize_with :solution, :user_track

    def call
      solution.with_lock do
        return if solution.completed?

        solution.update!(completed_at: Time.current)
      end

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

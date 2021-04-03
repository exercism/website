class Solution
  class Complete
    include Mandate

    initialize_with :solution, :user_track

    def call
      # TODO: Guard against already being completed

      ActiveRecord::Base.transaction do
        mark_concepts_as_learnt! if exercise.concept_exercise?
        mark_solution_as_complete!
      end
      record_activity!
    end

    private
    def mark_solution_as_complete!
      solution.update!(completed_at: Date.current)
    end

    def mark_concepts_as_learnt!
      exercise.taught_concepts.each do |concept|
        user_track.learnt_concepts << concept
      end
    end

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

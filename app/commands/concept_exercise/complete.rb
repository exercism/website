class ConceptExercise
  class Complete
    include Mandate

    initialize_with :user, :exercise

    def call
      guard!

      ActiveRecord::Base.transaction do
        mark_concepts_as_learnt!
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
        exercise: exercise
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end

    def guard!
      raise SolutionNotFoundError unless solution
      raise UserTrackNotFoundError unless user_track
    end

    def solution
      Solution.for(user, exercise)
    end

    def user_track
      UserTrack.for(user, exercise.track)
    end
  end
end

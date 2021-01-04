class Solution
  class Create
    include Mandate
    initialize_with :user, :exercise

    def call
      guard!

      solution_class.create_or_find_by!(
        user: user,
        exercise: exercise
      ).tap do |_solution|
        record_activity!
      end
    end

    private
    def guard!
      raise UserTrackNotFoundError unless user_track
      raise ExerciseUnavailableError unless user_track.exercise_available?(exercise)
    end

    def record_activity!
      User::Activity::Create.(
        :started_exercise,
        user,
        track: exercise.track,
        exercise: exercise
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end

    def solution_class
      case exercise
      when ConceptExercise
        ConceptSolution
      when PracticeExercise
        PracticeSolution
      else
        # Guard against some further third type
        raise RuntimeError
      end
    end

    def user_track
      UserTrack.for(user, exercise.track)
    end
  end
end

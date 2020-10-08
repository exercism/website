class Solution
  class Create
    include Mandate
    initialize_with :user, :exercise

    def call
      guard!

      solution_class.create_or_find_by!(
        user: user,
        exercise: exercise
      )
    end

    private
    def guard!
      raise UserTrackNotFoundError unless user_track
      raise ExerciseUnavailableError unless user_track.exercise_available?(exercise)
    end

    def solution_class
      if exercise.is_a?(ConceptExercise)
        ConceptSolution
      elsif exercise.is_a?(PracticeExercise)
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

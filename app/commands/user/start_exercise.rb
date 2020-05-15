class User
  class StartExercise
    include Mandate
    initialize_with :user_track, :exercise

    def call
      guard!

      solution_class.create_or_find_by!(
        user: user_track.user,
        exercise: exercise
      )
    end

    private
    def guard!
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
  end
end

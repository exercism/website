module ReactComponents
  module Student
    class ExerciseList < ReactComponent
      initialize_with :track

      def to_s
        super("student-exercise-list", { request: request })
      end

      private
      def data
        {
          exercises: SerializeExercises.(
            track.exercises.order('id'),
            user_track: UserTrack.for(current_user, track)
          ),
          solutions: SerializeSolutionsForStudent.(current_user.solutions.where(exercise_id: track.exercises))
        }
      end

      def request
        {
          endpoint: Exercism::Routes.api_track_exercises_path(track),
          options: {
            initial_data: data
          },
          query: { sideload: [:solutions] }
        }
      end
    end
  end
end

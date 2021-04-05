module ReactComponents
  module Student
    class ExerciseList < ReactComponent
      initialize_with :track

      def to_s
        super("student-exercise-list", {
          track: SerializeTrack.(track, UserTrack.for(current_user, track)),
          request: request
        })
      end

      private
      def data
        if current_user
          solutions = SerializeSolutions.(
            current_user.solutions.where(exercise_id: track.exercises),
            current_user
          )
        else
          solutions = []
        end

        {
          exercises: SerializeExercises.(
            track.exercises.sorted,
            user_track: UserTrack.for(current_user, track)
          ),
          solutions: solutions
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

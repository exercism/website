module ReactComponents
  module Student
    class ExerciseStatusChart < ReactComponent
      initialize_with :track

      def to_s
        super(
          "student-exercise-status-chart",
          {
            exercise_statuses: exercise_statuses,
            links: {
              exercise: Exercism::Routes.track_exercise_url(track, "$SLUG"),
              tooltip: Exercism::Routes.tooltip_track_exercise_url(track, "$SLUG")
            }
          }
        )
      end

      private
      def exercise_statuses
        user_track = UserTrack.for(current_user, track)

        track.exercises.each_with_object({}) do |exercise, hash|
          status = user_track.exercise_status(exercise)

          hash[exercise.slug] = status
        end
      end
    end
  end
end

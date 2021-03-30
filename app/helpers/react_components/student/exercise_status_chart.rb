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
          },
          style: "min-height: #{height}px"
        )
      end

      private
      def exercise_statuses
        user_track = UserTrack.for(current_user, track)

        exercises.each_with_object({}) do |exercise, hash|
          status = user_track.exercise_status(exercise)

          hash[exercise.slug] = status
        end
      end

      def height
        exercise_per_row = 23.0
        height_per_row = 33.6
        bottom_margin = 24

        num_rows = (exercises.size / exercise_per_row).ceil
        height_per_row * num_rows + bottom_margin
      end

      memoize
      def exercises
        track.exercises
      end
    end
  end
end

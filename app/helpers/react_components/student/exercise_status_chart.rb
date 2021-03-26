module ReactComponents
  module Student
    class ExerciseStatusChart < ReactComponent
      initialize_with :track

      def to_s
        super(
          "student-exercise-status-chart",
          {
            exercise_statuses: exercise_statuses
          }
        )
      end

      private
      def exercise_statuses
        user_track = UserTrack.for(current_user, track)

        track.exercises.map do |exercise|
          status = user_track.exercise_status(exercise)
          {
            slug: exercise.slug,
            status: status,
            links: if status != :locked
                     {
                       exercise: Exercism::Routes.track_exercise_url(track, exercise.slug)
                     }
                   else
                     {
                       tooltip: Exercism::Routes.tooltip_track_exercise_url(track, exercise.slug)
                     }
                   end
          }
        end
      end
    end
  end
end

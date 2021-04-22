module ReactComponents
  module Student
    class ExerciseStatusDot < ReactComponent
      initialize_with :exercise

      def to_s
        super(
          "student-exercise-status-dot",
          {
            slug: exercise.slug,
            exercise_status: exercise_status,
            type: exercise.git_type,
            links: {
              exercise: Exercism::Routes.track_exercise_url(exercise.track, exercise.slug),
              tooltip: Exercism::Routes.tooltip_track_exercise_url(exercise.track, exercise.slug)
            }
          }
        )
      end

      private
      def exercise_status
        user_track = UserTrack.for(current_user, exercise.track)

        user_track.exercise_status(exercise)
      end
    end
  end
end

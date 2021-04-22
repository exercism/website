module ReactComponents
  module Student
    class ExerciseStatusDot < ReactComponent
      def initialize(exercise, user_track)
        @exercise = exercise
        @user_track = user_track || UserTrack::External.new(exercise.track)

        super()
      end

      def to_s
        super(
          "student-exercise-status-dot",
          {
            slug: exercise.slug,
            exercise_status: user_track.exercise_status(exercise),
            type: exercise.git_type,
            links: {
              exercise: Exercism::Routes.track_exercise_url(exercise.track, exercise.slug),
              tooltip: Exercism::Routes.tooltip_track_exercise_url(exercise.track, exercise.slug)
            }
          }
        )
      end

      private
      attr_reader :exercise, :user_track
    end
  end
end

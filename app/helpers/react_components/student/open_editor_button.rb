module ReactComponents
  module Student
    class OpenEditorButton < ReactComponent
      initialize_with :exercise, :user_track

      def to_s
        return if user_track.external?

        super(
          "student-open-editor-button",
          {
            status:,
            command:,
            editor_enabled: exercise.has_test_runner?,
            links:
          }
        )
      end

      private
      memoize
      def status
        user_track.exercise_status(exercise)
      end

      memoize
      def command
        exercise.download_cmd
      end

      memoize
      def links
        {
          start: Exercism::Routes.start_api_track_exercise_path(exercise.track, exercise),
          exercise: Exercism::Routes.edit_track_exercise_path(exercise.track, exercise),
          local: Exercism::Routes.doc_path(:using, "solving-exercises/working-locally")
        }
      end
    end
  end
end

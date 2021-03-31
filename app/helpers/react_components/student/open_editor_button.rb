module ReactComponents
  module Student
    class OpenEditorButton < ReactComponent
      initialize_with :exercise

      def to_s
        return if user_track.external?

        super(
          "student-open-editor-button",
          {
            status: status,
            command: command,
            links: links
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
        @command ||= exercise.download_cmd
      end

      memoize
      def links
        {
          start: Exercism::Routes.start_track_exercise_path(exercise.track, exercise),
          exercise: Exercism::Routes.edit_track_exercise_path(exercise.track, exercise)
        }
      end

      memoize
      def user_track
        UserTrack.for(current_user, exercise.track, external_if_missing: true)
      end
    end
  end
end

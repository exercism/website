module ReactComponents
  module Student
    class OpenEditorButton < ReactComponent
      initialize_with :exercise

      def to_s
        super(
          "student-open-editor-button",
          {
            status: status,
            links: links
          }
        )
      end

      private
      def status
        @status ||= user_track.exercise_status(exercise)
      end

      def links
        {
          start: Exercism::Routes.start_track_exercise_path(exercise.track, exercise)
        }
      end

      def user_track
        @user_track ||= UserTrack.for(current_user, exercise.track)
      end
    end
  end
end

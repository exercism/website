module ReactComponents
  module Student
    class IterationPage < ReactComponent
      initialize_with :iterations, :track, :exercise

      def to_s
        super(
          "student-iteration-report",
          {
            iterations: iterations.map { |iteration| SerializeIteration.(iteration) },
            exercise: {
              title: exercise.title
            },
            track: {
              title: track.title,
              icon_url: track.icon_url,
              highlightjs_language: track.highlightjs_language
            },
            links: {
              get_mentoring: Exercism::Routes.track_exercise_mentoring_index_url(track, exercise),
              automated_feedback_info: "TODO"
            }
          }
        )
      end
    end
  end
end

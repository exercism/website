module ReactComponents
  module Student
    class IterationPage < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-iteration-page",
          {
            solution_uuid: solution.uuid,
            request: request,
            exercise: {
              title: exercise.title,
              download_cmd: exercise.download_cmd
            },
            track: {
              title: track.title,
              icon_url: track.icon_url,
              highlightjs_language: track.highlightjs_language,
              indent_size: track.indent_size
            },
            links: {
              get_mentoring: Exercism::Routes.new_track_exercise_mentor_request_url(track, exercise),
              automated_feedback_info: "TODO", # TODO: (Required)
              start_exercise: Exercism::Routes.start_temp_track_exercise_url(track, exercise),
              solving_exercises_locally: "TODO" # TODO: (Required)
            }
          }
        )
      end

      private
      delegate :exercise, :track, to: :solution

      def request
        {
          endpoint: Exercism::Routes.api_solution_url(solution.uuid, sideload: [:iterations]),
          options: {
            initialData: {
              iterations: solution.
                iterations.
                order(id: :desc).
                map { |iteration| SerializeIteration.(iteration, sideload: [:files]) }
            }
          }
        }
      end
    end
  end
end

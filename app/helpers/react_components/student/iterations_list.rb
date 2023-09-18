module ReactComponents
  module Student
    class IterationsList < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-iterations-list",
          {
            solution_uuid: solution.uuid,
            request:,
            exercise: {
              title: exercise.title,
              slug: exercise.slug,
              download_cmd: exercise.download_cmd,
              has_test_runner: exercise.has_test_runner?
            },
            track: {
              title: track.title,
              slug: track.slug,
              icon_url: track.icon_url,
              highlightjs_language: track.highlightjs_language,
              indent_size: track.indent_size
            },
            links: {
              get_mentoring: Exercism::Routes.new_track_exercise_mentor_request_url(track, exercise),
              tooling_help: Exercism::Routes.doc_path('building', 'tooling'),
              automated_feedback_info: Exercism::Routes.doc_path('using', 'feedback/automated'),
              start_exercise: Exercism::Routes.start_api_track_exercise_url(track, exercise),
              solving_exercises_locally: Exercism::Routes.solving_exercises_locally_path
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
            initial_data: {
              iterations: SerializeIterations.(solution.iterations.order(id: :desc), sideload: %i[files automated_feedback])
            },
            initial_data_updated_at: Time.current.to_i
          }
        }
      end
    end
  end
end

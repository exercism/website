module ReactComponents
  module Student
    class SolutionSummary < ReactComponent
      initialize_with :solution

      def to_s
        super("student-solution-summary", {
          solution_id: solution.uuid,
          request: request,
          is_practice_exercise: solution.exercise.practice_exercise?,
          links: links
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.temp_solution_url(solution.uuid),
          options: {
            initialData: {
              latest_iteration: SerializeIteration.(solution.latest_iteration)
            }
          }
        }
      end

      def links
        {
          tests_passed_locally_article: "#",
          all_iterations: Exercism::Routes.track_concepts_path(solution.track),
          community_solutions: "#",
          learn_more_about_mentoring_article: "#",
          mentoring_info: "#",
          complete_exercise: Exercism::Routes.complete_api_solution_url(solution.uuid)
        }
      end
    end
  end
end

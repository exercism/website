module ReactComponents
  module Student
    class SolutionSummary < ReactComponent
      initialize_with :solution

      def to_s
        super("student-solution-summary", {
          solution_id: solution.uuid,
          request: request,
          is_concept_exercise: solution.exercise.concept_exercise?,
          links: links
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_solution_url(solution.uuid, sideload: [:iterations]),
          options: {
            initialData: {
              iterations: solution.
                iterations.
                order(id: :desc).
                map { |iteration| SerializeIteration.(iteration) }
            }
          }
        }
      end

      def links
        {
          tests_passed_locally_article: "#",
          all_iterations: Exercism::Routes.track_exercise_iterations_path(solution.track, solution.exercise),
          community_solutions: "#",
          learn_more_about_mentoring_article: "#"
        }
      end
    end
  end
end

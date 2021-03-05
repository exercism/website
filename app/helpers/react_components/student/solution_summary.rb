module ReactComponents
  module Student
    class SolutionSummary < ReactComponent
      initialize_with :iteration

      def to_s
        super("student-solution-summary", {
          solution_id: iteration.solution.uuid,
          request: request,
          is_concept_exercise: iteration.exercise.concept_exercise?,
          links: links
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.temp_solution_url(iteration.solution.uuid),
          options: {
            initialData: {
              latest_iteration: SerializeIteration.(iteration)
            }
          }
        }
      end

      def links
        {
          tests_passed_locally_article: "#",
          all_iterations: Exercism::Routes.track_concepts_path(iteration.track),
          community_solutions: "#",
          learn_more_about_mentoring_article: "#"
        }
      end
    end
  end
end

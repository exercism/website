module ReactComponents
  module Student
    class PublishedSolution < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-published-solution",
          {
            solution: SerializeCommunitySolution.(solution),
            published_iteration_idx: solution.published_iteration.try(:idx),
            iterations: solution.iterations.order(idx: :desc).map { |iteration| SerializeIteration.(iteration) },
            links: {
              change_iteration: Exercism::Routes.published_iteration_api_solution_url(solution.uuid),
              unpublish: Exercism::Routes.unpublish_api_solution_url(solution.uuid)
            }
          }
        )
      end
    end
  end
end

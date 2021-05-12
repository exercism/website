module ReactComponents
  module Student
    class PublishSettings < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-publish-settings",
          {
            endpoint: Exercism::Routes.published_iteration_api_solution_url(solution.uuid),
            published_iteration_idx: solution.published_iteration.try(:idx),
            iterations: solution.iterations.order(idx: :desc).map { |iteration| SerializeIteration.(iteration) }
          }
        )
      end
    end
  end
end

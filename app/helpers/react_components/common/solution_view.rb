module ReactComponents
  module Common
    class SolutionView < ReactComponent
      initialize_with :solution

      def to_s
        super("common-solution-view", {
          iterations: solution.published_iterations.map { |iteration| SerializeIteration.(iteration) },
          language: solution.track.highlightjs_language,
          published_iteration_idx: solution.published_iteration.try(:idx),
          links: {
            change_iteration: change_iteration_link,
            unpublish: unpublish_link
          }
        })
      end

      def change_iteration_link
        return unless solution.user == current_user

        Exercism::Routes.published_iteration_api_solution_url(solution.uuid)
      end

      def unpublish_link
        return unless solution.user == current_user

        Exercism::Routes.unpublish_api_solution_url(solution.uuid)
      end
    end
  end
end

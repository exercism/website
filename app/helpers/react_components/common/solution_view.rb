module ReactComponents
  module Common
    class SolutionView < ReactComponent
      initialize_with :solution

      def to_s
        super("common-solution-view", {
          iterations: SerializeIterations.(iterations),
          language: solution.track.highlightjs_language,
          indent_size: solution.track.indent_size,
          out_of_date: solution.out_of_date?,
          published_iteration_idx: solution.published_iteration.try(:idx),
          published_iteration_idxs: solution.published_iterations.pluck(:idx),
          links: {
            change_iteration: change_iteration_link,
            unpublish: unpublish_link
          }
        })
      end

      private
      def iterations
        return solution.iterations.not_deleted if solution.user == current_user

        solution.published_iterations
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

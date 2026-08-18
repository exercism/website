module ReactComponents
  module Common
    class SolutionView < ReactComponent
      initialize_with :solution

      def to_s
        super("common-solution-view", data)
      end

      private
      # The author sees unpublished iterations and gets extra links, so
      # their variant is always rendered live. Everyone else gets the
      # published-only payload, served from the S3 cache when warm (see
      # Solution::CacheSerializedView::Retrieve). The author-only links
      # live outside the cached payload by design.
      def data
        if author?
          author_data
        else
          Solution::CacheSerializedView::Retrieve.(solution).merge(
            links: { change_iteration: nil, unpublish: nil }
          )
        end
      end

      def author_data
        {
          iterations: SerializeIterations.(solution.iterations.not_deleted),
          language: solution.track.highlightjs_language,
          indent_size: solution.track.indent_size,
          out_of_date: solution.out_of_date?,
          published_iteration_idx: solution.published_iteration.try(:idx),
          published_iteration_idxs: solution.published_iterations.pluck(:idx),
          links: {
            change_iteration: Exercism::Routes.published_iteration_api_solution_url(solution.uuid),
            unpublish: Exercism::Routes.unpublish_api_solution_url(solution.uuid)
          }
        }
      end

      def author? = solution.user == current_user
    end
  end
end

module ReactComponents
  module CommunitySolutions
    class CommentsList < ReactComponent
      initialize_with :solution

      def to_s
        super("community-solutions-comments-list", {
          allow_comments: solution.allow_comments,
          is_author: current_user == solution.user,
          request: {
            endpoint: Exercism::Routes.api_track_exercise_community_solution_comments_url(
              solution.track,
              solution.exercise,
              solution.user.handle
            ),
            options: {
              initial_data: AssembleCommunitySolutionsCommentsList.(solution, current_user)
            }
          },
          iterations: solution.published_iterations.map { |iteration| SerializeIteration.(iteration) },
          published_iteration_idx: solution.published_iteration.try(:idx),
          links: {
            create: Exercism::Routes.api_track_exercise_community_solution_comments_url(
              solution.track,
              solution.exercise,
              solution.user.handle
            ),
            change_iteration: change_iteration_link,
            unpublish: unpublish_link
          }
        })
      end

      private
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

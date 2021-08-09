module ReactComponents
  module CommunitySolutions
    class CommentsList < ReactComponent
      initialize_with :solution

      def to_s
        super("community-solutions-comments-list", {
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
          links: {
            create: Exercism::Routes.api_track_exercise_community_solution_comments_url(
              solution.track,
              solution.exercise,
              solution.user.handle
            )
          }
        })
      end
    end
  end
end

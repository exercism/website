module ReactComponents
  module CommunitySolutions
    class CommentsList < ReactComponent
      initialize_with :solution

      def to_s
        super("community-solutions-comments-list", {
          user_signed_in: current_user.present?,
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
          links: {
            create: Exercism::Routes.api_track_exercise_community_solution_comments_url(
              solution.track,
              solution.exercise,
              solution.user.handle
            ),
            enable: Exercism::Routes.enable_api_track_exercise_community_solution_comments_url(
              solution.track,
              solution.exercise,
              solution.user.handle
            ),
            disable: Exercism::Routes.disable_api_track_exercise_community_solution_comments_url(
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

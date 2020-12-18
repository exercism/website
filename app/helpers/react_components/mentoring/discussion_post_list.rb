module ReactComponents
  module Mentoring
    class DiscussionPostList < ReactComponent
      initialize_with :discussion, :iteration

      def to_s
        super(
          "mentoring-discussion-post-list",
          {
            endpoint: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_id: iteration.id)
          }
        )
      end
    end
  end
end

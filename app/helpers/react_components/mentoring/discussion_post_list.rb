module ReactComponents
  module Mentoring
    class DiscussionPostList < ReactComponent
      initialize_with :discussion, :iteration

      def to_s
        super(
          "mentoring-discussion-post-list",
          {
            discussion_id: discussion.uuid,
            iteration_idx: iteration.idx,
            endpoint: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_idx: iteration.idx)
          }
        )
      end
    end
  end
end

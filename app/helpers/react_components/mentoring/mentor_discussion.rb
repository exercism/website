module ReactComponents
  module Mentoring
    class MentorDiscussion < ReactComponent
      initialize_with :discussion, :iteration

      def to_s
        scratchpad = ScratchpadPage.new(about: discussion.solution.exercise)

        super(
          "mentoring-mentor-discussion",
          {
            discussion_id: discussion.uuid,
            iteration_idx: iteration.idx,
            links: {
              posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_idx: iteration.idx),
              scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
            }
          }
        )
      end
    end
  end
end

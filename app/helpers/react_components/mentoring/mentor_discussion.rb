module ReactComponents
  module Mentoring
    class MentorDiscussion < ReactComponent
      initialize_with :discussion

      def to_s
        scratchpad = ScratchpadPage.new(about: discussion.solution.exercise)

        super(
          "mentoring-mentor-discussion",
          {
            discussion_id: discussion.uuid,
            iterations: discussion.solution.iterations.map do |iteration|
              {
                idx: iteration.idx,
                links: {
                  posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_idx: iteration.idx)
                }
              }
            end,
            links: {
              scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
            }
          }
        )
      end
    end
  end
end

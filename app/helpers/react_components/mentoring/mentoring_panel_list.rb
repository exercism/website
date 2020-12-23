module ReactComponents
  module Mentoring
    class MentoringPanelList < ReactComponent
      initialize_with :discussion, :iteration

      def to_s
        super(
          "mentoring-mentoring-panel-list",
          {
            discussion_id: discussion.uuid,
            iteration_idx: iteration.idx,
            links: {
              posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_idx: iteration.idx),
              scratchpad: Exercism::Routes.api_track_exercise_scratchpad_page_url(discussion.solution.track,
                discussion.solution.exercise)
            }
          }
        )
      end
    end
  end
end

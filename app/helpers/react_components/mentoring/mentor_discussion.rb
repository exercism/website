module ReactComponents
  module Mentoring
    class MentorDiscussion < ReactComponent
      initialize_with :discussion

      def to_s
        scratchpad = ScratchpadPage.new(about: discussion.solution.exercise)
        student = discussion.solution.user
        track = discussion.solution.track
        exercise = discussion.solution.exercise

        super(
          "mentoring-mentor-discussion",
          {
            discussion_id: discussion.uuid,
            student: {
              avatar_url: student.avatar_url,
              handle: student.handle
            },
            track: {
              title: track.title,
              icon_url: track.icon_url
            },
            exercise: {
              title: exercise.title
            },
            iterations: discussion.solution.iterations.map do |iteration|
              {
                idx: iteration.idx,
                num_comments: Solution::MentorDiscussionPost.where(discussion: discussion, iteration: iteration).count,
                # TODO: @iHiD, I don't know how to get the correct unread state
                unread: true,
                links: {
                  posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_idx: iteration.idx)
                }
              }
            end,
            links: {
              exercise: Exercism::Routes.track_exercise_path(track, exercise),
              scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
            }
          }
        )
      end
    end
  end
end

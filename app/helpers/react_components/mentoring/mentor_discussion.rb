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
            iterations: iterations,
            links: {
              exercise: Exercism::Routes.track_exercise_path(track, exercise),
              scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
            }
          }
        )
      end

      def iterations
        comment_counts = Solution::MentorDiscussionPost.where(discussion: discussion).
          group(:iteration_id, :seen_by_mentor).count

        discussion.solution.iterations.map do |iteration|
          ccs = comment_counts.select { |(it_id, _), _| it_id == iteration.id }

          {
            idx: iteration.idx,
            num_comments: ccs.sum(&:second),
            unread: ccs.reject { |(_, seen), _| seen }.present?,
            links: {
              posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_idx: iteration.idx)
            }
          }
        end
      end
    end
  end
end

module ReactComponents
  module Mentoring
    class Discussion < ReactComponent
      initialize_with :discussion

      def to_s
        super(
          "mentoring-discussion",
          {
            discussion_id: discussion.uuid,
            student: {
              avatar_url: student.avatar_url,
              handle: student.handle
            },
            track: {
              title: track.title,
              highlightjs_language: track.highlightjs_language,
              icon_url: track.icon_url
            },
            exercise: {
              title: exercise.title
            },
            iterations: iterations,
            links: links
          }
        )
      end

      def links
        {
          exercise: Exercism::Routes.track_exercise_path(track, exercise),
          scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
        }.tap do |links|
          if discussion.requires_mentor_action?
            links[:mark_as_nothing_to_do] = Exercism::Routes.mark_as_nothing_to_do_api_mentor_discussion_path(discussion)
          end
        end
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
            created_at: iteration.created_at.iso8601,
            links: {
              files: Exercism::Routes.api_submission_files_url(iteration.submission),
              posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion, iteration_idx: iteration.idx)
            }
          }
        end
      end

      memoize
      def student
        discussion.solution.user
      end

      memoize
      def track
        discussion.solution.track
      end

      memoize
      def exercise
        discussion.solution.exercise
      end

      memoize
      def scratchpad
        ScratchpadPage.new(about: exercise)
      end
    end
  end
end

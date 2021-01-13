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
              name: student.name,
              handle: student.handle,
              bio: student.bio,
              languages_spoken: student.languages_spoken,
              avatar_url: student.avatar_url,
              reputation: student.reputation,
              is_favorite: student.favorited_by?(mentor),
              num_previous_sessions: mentor.num_previous_mentor_sessions_with(student),
              links: {
                # TODO
                favorite: "stub_link"
              }
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
          scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title),
          posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion)
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
            uuid: iteration.uuid,
            idx: iteration.idx,
            num_comments: ccs.sum(&:second),
            unread: ccs.reject { |(_, seen), _| seen }.present?,
            created_at: iteration.created_at.iso8601,
            tests_status: iteration.tests_status,
            links: {
              files: Exercism::Routes.api_submission_files_url(iteration.submission)
            }
          }
        end
      end

      memoize
      delegate :student, to: :discussion

      memoize
      delegate :mentor, to: :discussion

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

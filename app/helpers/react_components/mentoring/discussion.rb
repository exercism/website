module ReactComponents
  module Mentoring
    class Discussion < ReactComponent
      initialize_with :discussion

      def to_s
        super(
          "mentoring-discussion",
          {
            discussion_id: discussion.uuid,
            user_id: current_user.id,
            mentor: {
              handle: mentor.handle,
              avatar_url: mentor.avatar_url
            },
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
                favorite: Exercism::Routes.api_mentor_favorite_student_path(student_handle: student.handle)
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
            mentor_solution: mentor_solution,
            notes: notes,
            links: links
          }
        )
      end

      def links
        {
          mentor_dashboard: Exercism::Routes.mentor_dashboard_path,
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
            # TODO: Precalculate this to avoid n+1s
            automated_feedback: iteration.automated_feedback,
            links: {
              files: Exercism::Routes.api_submission_files_url(iteration.submission)
            }
          }
        end
      end

      def mentor_solution
        ms = Solution.for(mentor, exercise)
        return nil unless ms

        {
          snippet: ms.snippet,
          num_loc: ms.num_loc,
          num_stars: ms.num_stars,
          num_comments: ms.num_comments,
          published_at: ms.published_at,
          web_url: Exercism::Routes.private_solution_url(ms)
        }
      end

      # TODO
      def notes
        '
<h3>Talking points</h3>
<ul>
  <li>
    <code>each_cons</code> instead of an iterator
    <code>with_index</code>: In Ruby, you rarely have to write
    iterators that need to keep track of the index. Enumerable has
    powerful methods that do that for us.
  </li>
  <li>
    <code>chars</code>: instead of <code>split("")</code>.
  </li>
</ul>
        '.strip
      end

      memoize
      delegate :student, :mentor, :exercise, :track, to: :discussion

      memoize
      def scratchpad
        ScratchpadPage.new(about: exercise)
      end
    end
  end
end

module ReactComponents
  module Mentoring
    class Solution < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "mentoring-solution",
          {
            user_id: current_user.id,
            student: {
              name: student.name,
              handle: student.handle,
              bio: student.bio,
              languages_spoken: student.languages_spoken,
              avatar_url: student.avatar_url,
              reputation: student.reputation,
              is_favorite: student.favorited_by?(current_user),
              num_previous_sessions: current_user.num_previous_mentor_sessions_with(student),
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
            links: links,
            relationship: SerializeMentorStudentRelationship.(student_mentor_relationship),
            request: request_json,
            discussion: discussion_json
          }
        )
      end

      memoize
      def request
        ::Solution::MentorRequest.find_by(solution: solution)
      end

      def request_json
        return if request.blank?

        {
          comment: request.comment,
          updated_at: request.updated_at
        }
      end

      def discussion
        ::Solution::MentorDiscussion.find_by(solution: solution, mentor: current_user)
      end

      def student_mentor_relationship
        Mentor::StudentRelationship.find_by(mentor: current_user, student: student)
      end

      def discussion_json
        return if discussion.blank?

        {
          id: discussion.uuid,
          is_finished: discussion.finished?,
          links: { posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion) }.tap do |links|
            if discussion.requires_mentor_action?
              links[:mark_as_nothing_to_do] =
                Exercism::Routes.mark_as_nothing_to_do_api_mentor_discussion_path(discussion)
            end

            links[:finish] = Exercism::Routes.finish_api_mentor_discussion_path(discussion) unless discussion.finished?
          end
        }
      end

      def links
        {
          mentor_dashboard: Exercism::Routes.mentor_dashboard_path,
          exercise: Exercism::Routes.track_exercise_path(track, exercise),
          scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
        }
      end

      def iterations
        comment_counts = if discussion
                           ::Solution::MentorDiscussionPost.where(discussion: discussion).
                             group(:iteration_id, :seen_by_mentor).count
                         end

        solution.iterations.map do |iteration|
          discussion ? counts = comment_counts.select { |(it_id, _), _| it_id == iteration.id } : counts = nil
          discussion ? num_comments = counts.sum(&:second) : num_comments = 0
          discussion ? unread = counts.reject { |(_, seen), _| seen }.present? : unread = 0

          {
            uuid: iteration.uuid,
            idx: iteration.idx,
            num_comments: num_comments,
            unread: unread,
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
        ms = ::Solution.for(current_user, exercise)

        return nil unless ms

        {
          snippet: ms.snippet,
          num_loc: ms.num_loc,
          num_stars: ms.num_stars,
          num_comments: ms.num_comments,
          published_at: ms.published_at,
          web_url: Exercism::Routes.private_solution_url(ms),
          mentor: {
            handle: current_user.handle,
            avatar_url: current_user.avatar_url
          },
          language: ms.editor_language
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
      delegate :exercise, :track, to: :solution

      def student
        solution.user
      end

      memoize
      def scratchpad
        ScratchpadPage.new(about: exercise)
      end
    end
  end
end

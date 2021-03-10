module ReactComponents
  module Mentoring
    class Session < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "mentoring-session",
          {
            user_id: current_user.id,
            student: {
              id: student.id,
              name: student.name,
              handle: student.handle,
              bio: student.bio,
              languages_spoken: student.languages_spoken,
              avatar_url: student.avatar_url,
              reputation: student.reputation,
              is_favorite: student.favorited_by?(current_user),
              num_previous_sessions: current_user.num_previous_mentor_sessions_with(student),
              links: {
                favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle)
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
            request: SerializeMentorRequest.(request),
            discussion: SerializeMentorDiscussion.(discussion, current_user)
          }
        )
      end

      memoize
      def request
        ::Solution::MentorRequest.find_by(solution: solution)
      end

      def discussion
        ::Solution::MentorDiscussion.find_by(solution: solution, mentor: current_user)
      end

      def student_mentor_relationship
        Mentor::StudentRelationship.find_by(mentor: current_user, student: student)
      end

      def links
        {
          mentor_dashboard: Exercism::Routes.mentoring_dashboard_path,
          exercise: Exercism::Routes.track_exercise_path(track, exercise),
          scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
        }
      end

      def iterations
        if discussion
          comment_counts = ::Solution::MentorDiscussionPost.
            where(discussion: discussion).
            group(:iteration_id, :seen_by_student).
            count
        end

        solution.iterations.map do |iteration|
          counts = discussion ? comment_counts.select { |(it_id, _), _| it_id == iteration.id } : nil
          num_comments = discussion ? counts.sum(&:second) : 0
          unread = discussion ? counts.reject { |(_, seen), _| seen }.present? : 0

          SerializeIteration.(iteration).merge(num_comments: num_comments, unread: unread)
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

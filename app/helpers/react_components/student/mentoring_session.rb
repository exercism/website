module ReactComponents
  module Student
    class MentoringSession < ReactComponent
      initialize_with :discussion

      def to_s
        super(
          "student-mentoring-session",
          {
            id: discussion.uuid,
            is_finished: discussion.finished?,
            user_id: current_user.id,
            mentor: {
              id: mentor.id,
              name: mentor.name,
              handle: mentor.handle,
              bio: mentor.bio,
              languages_spoken: mentor.languages_spoken,
              avatar_url: mentor.avatar_url,
              reputation: mentor.reputation,
              num_previous_sessions: current_user.num_previous_mentor_sessions_with(mentor)
            },
            exercise: {
              title: exercise.title,
              icon_name: exercise.icon_name
            },
            track: {
              title: track.title,
              highlightjs_language: track.highlightjs_language,
              icon_url: track.icon_url
            },
            iterations: iterations,
            links: {
              posts: Exercism::Routes.api_solution_discussion_posts_url(discussion.solution.uuid, discussion),
              exercise: Exercism::Routes.track_exercise_url(track, exercise)
            }
          }
        )
      end

      private
      delegate :mentor, :track, :exercise, to: :discussion

      def iterations
        comment_counts = ::Solution::MentorDiscussionPost.
          where(discussion: discussion).
          group(:iteration_id, :seen_by_student).
          count

        discussion.iterations.map do |iteration|
          counts = comment_counts.select { |(it_id, _), _| it_id == iteration.id }
          num_comments = counts.sum(&:second)
          unread = counts.reject { |(_, seen), _| seen }.present?

          SerializeIteration.(iteration).merge(num_comments: num_comments, unread: unread)
        end
      end
    end
  end
end

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
            student: {
              handle: student.handle
            },
            partner: {
              name: mentor.name,
              handle: mentor.handle,
              bio: mentor.bio,
              languages_spoken: mentor.languages_spoken,
              avatar_url: mentor.avatar_url,
              reputation: mentor.reputation,
              num_previous_sessions: current_user.num_previous_mentor_sessions_with(mentor)
            },
            track: {
              title: track.title,
              highlightjs_language: track.highlightjs_language,
              icon_url: track.icon_url
            },
            iterations: iterations,
            links: {
              posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion)
            }
          }
        )
      end

      private
      delegate :student, :mentor, :track, to: :discussion

      def iterations
        comment_counts = ::Solution::MentorDiscussionPost.
          where(discussion: discussion).
          group(:iteration_id, :seen_by_mentor).
          count

        discussion.iterations.map do |iteration|
          counts = comment_counts.select { |(it_id, _), _| it_id == iteration.id }
          num_comments = counts.sum(&:second)
          unread = counts.reject { |(_, seen), _| seen }.present?

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
    end
  end
end

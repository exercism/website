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
            iterations: iterations,
            links: {
              posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion)
            }
          }
        )
      end

      private
      delegate :student, to: :discussion

      def iterations
        discussion.solution.iterations.map do |iteration|
          {
            idx: iteration.idx,
            created_at: iteration.created_at.iso8601,
            automated_feedback: iteration.automated_feedback
          }
        end
      end
    end
  end
end

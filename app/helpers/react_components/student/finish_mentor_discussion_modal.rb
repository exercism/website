module ReactComponents
  module Student
    class FinishMentorDiscussionModal < ReactComponent
      initialize_with :discussion

      def to_s
        super("student-finish-mentor-discussion-modal", {
          links: links
        })
      end

      private
      def links
        {
          exercise: Exercism::Routes.track_exercise_path(discussion.track, discussion.exercise),
          finish: Exercism::Routes.finish_api_solution_discussion_url(discussion.solution.uuid, discussion.uuid)
        }
      end
    end
  end
end

module ReactComponents
  module Student
    class MentoringDropdown < ReactComponent
      initialize_with :solution

      def to_s
        super("student-mentoring-dropdown", {
          has_mentor_discussion_in_progress: solution.mentor_discussions.in_progress.any?,
          discussions: discussions,
          links: {
            share: "https://some.link/we/need/to-decide-on"
          }
        })
      end

      private
      def discussions
        solution.mentor_discussions.map do |discussion|
          {
            id: discussion.uuid,
            mentor: {
              avatar_url: discussion.mentor.avatar_url,
              handle: discussion.mentor.handle
            },
            is_finished: discussion.finished?,
            is_unread: discussion.posts.where(seen_by_student: false).exists?,
            posts_count: discussion.posts.count,
            created_at: discussion.created_at.iso8601,
            links: {
              self: Exercism::Routes.mentoring_discussion_url(discussion.uuid)
            }
          }
        end
      end
    end
  end
end

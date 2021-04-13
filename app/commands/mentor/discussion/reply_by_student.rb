module Mentor
  class Discussion
    class ReplyByStudent
      include Mandate

      initialize_with :discussion, :iteration, :content_markdown

      def call
        discussion_post = Mentor::DiscussionPost.create!(
          iteration: iteration,
          discussion: discussion,
          content_markdown: content_markdown,
          author: iteration.solution.user,
          seen_by_student: true
        )

        discussion.mentor_action_required!

        User::Notification::Create.(
          discussion.mentor,
          :student_replied_to_discussion,
          { discussion_post: discussion_post }
        )

        discussion_post
      end
    end
  end
end

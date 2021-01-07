class Solution
  class MentorDiscussion
    class ReplyByStudent
      include Mandate

      initialize_with :discussion, :iteration, :content_markdown

      def call
        discussion_post = Solution::MentorDiscussionPost.create!(
          iteration: iteration,
          discussion: discussion,
          content_markdown: content_markdown,
          author: iteration.solution.user,
          seen_by_student: true
        )

        Notification::Create.(
          discussion.mentor,
          :student_replied_to_discussion,
          { discussion_post: discussion_post }
        )

        discussion_post
      end
    end
  end
end

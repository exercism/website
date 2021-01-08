class Solution
  class MentorDiscussion
    class ReplyByMentor
      include Mandate

      initialize_with :discussion, :iteration, :content_markdown

      def call
        discussion_post = Solution::MentorDiscussionPost.create!(
          iteration: iteration,
          discussion: discussion,
          content_markdown: content_markdown,
          author: discussion.mentor,
          seen_by_mentor: true
        )

        Notification::Create.(
          iteration.solution.user,
          :mentor_replied_to_discussion,
          { discussion_post: discussion_post }
        )

        discussion_post
      end
    end
  end
end

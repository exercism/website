class Solution
  class MentorDiscussion
    class ReplyByStudent
      include Mandate

      initialize_with :discussion, :iteration_idx, :content_markdown

      def call
        discussion_post = Solution::MentorDiscussionPost.create!(
          iteration: iteration,
          discussion: discussion,
          content_markdown: content_markdown,
          author: iteration.solution.user
        )

        Notification::Create.(
          discussion.mentor,
          :student_replied_to_discussion,
          { discussion_post: discussion_post }
        )

        discussion_post
      end

      memoize
      def iteration
        discussion.solution.iterations.find_by!(idx: iteration_idx)
      end
    end
  end
end

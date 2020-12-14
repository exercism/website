class Solution
  class MentorDiscussion
    class Create
      include Mandate

      initialize_with :mentor, :request, :iteration, :content_markdown

      # TODO: Guard against a user mentoring their own solution
      def call
        ActiveRecord::Base.transaction do
          request.lock!

          raise SolutionLockedByAnotherMentorError unless request.lockable_by?(mentor)

          # Now we're in the happy path.
          # Mark the request as fulfilled, create the discussion
          # and a first post. If any of these fail then the
          # whole load need to fail.
          request.fulfilled!

          discussion = Solution::MentorDiscussion.create!(
            mentor: mentor,
            request: request
          )

          discussion_post = Solution::MentorDiscussionPost.create!(
            iteration: iteration,
            discussion: discussion,
            author: mentor,
            content_markdown: content_markdown
          )

          Notification::Create.(
            request.solution.user,
            :mentor_started_discussion,
            {
              discussion: discussion,
              discussion_post: discussion_post
            }
          )

          discussion
        end
      end
    end
  end
end

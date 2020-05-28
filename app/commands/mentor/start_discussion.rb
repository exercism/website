module Mentor
  class StartDiscussion

    include Mandate

    initialize_with :mentor, :request, :iteration, :content_markdown

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

        Iteration::DiscussionPost.create!(
          iteration: iteration,
          source: discussion,
          user: mentor,
          content_markdown: content_markdown
        )

        Notification::Create.(
          solution.user,
          :mentor_discussion_started,
          {
            discussion: discussion
          }
        )
      end
    end

    private 
    def solution
      request.solution
    end
  end
end


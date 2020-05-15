module Mentor
  class StartDiscussion
    include Mandate

    initialize_with :mentor, :request, :iteration, :content_markdown

    def call
      ActiveRecord::Base.transaction do
        request.fulfilled!

        discussion = Solution::MentorDiscussion.create!(
          mentor: mentor,
          request: request
        )

        Solution::DiscussionPost.create!(
          iteration: iteration,
          discussion: discussion,
          content_markdown: content_markdown
        )
      end
    end
  end
end


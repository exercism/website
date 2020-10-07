module Mentor
  class ReplyToDiscussion
    include Mandate

    initialize_with :discussion, :submission, :content_markdown

    def call
      discussion_post = Submission::DiscussionPost.create!(
        submission: submission,
        source: discussion,
        content_markdown: content_markdown,
        user: discussion.mentor
      )

      Notification::Create.(
        solution.user,
        :mentor_replied_to_discussion,
        { discussion_post: discussion_post }
      )

      discussion_post
    end

    private
    memoize
    def solution
      submission.solution
    end
  end
end

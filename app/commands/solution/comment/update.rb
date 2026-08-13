class Solution::Comment::Update
  include Mandate

  initialize_with :comment, :content_markdown

  def call
    return false unless comment.update(content_markdown:)

    Solution::InvalidateCloudflareCache.defer(comment.solution)

    # TODO: Readd this
    # CommentListChannel.notify!(comment.solution)

    true
  end
end

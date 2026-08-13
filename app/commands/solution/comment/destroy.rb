class Solution::Comment::Destroy
  include Mandate

  initialize_with :comment

  def call
    solution = comment.solution

    return false unless comment.destroy

    Solution::InvalidateCloudflareCache.defer(solution)

    # TODO: Readd this
    # CommentListChannel.notify!(solution)

    true
  end
end

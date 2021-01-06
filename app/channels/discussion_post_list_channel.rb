class DiscussionPostListChannel < ApplicationCable::Channel
  def self.notify!(discussion, iteration)
    broadcast_to("#{discussion.uuid}_#{iteration.idx}", {})
  end

  def subscribed
    discussion = Solution::MentorDiscussion.find_by!(uuid: params[:discussion_id])

    return unless discussion.viewable_by?(current_user)

    iteration = discussion.solution.iterations.find_by!(idx: params[:iteration_idx])

    stream_for "#{discussion.uuid}_#{iteration.idx}"
  end
end

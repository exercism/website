class DiscussionPostListChannel < ApplicationCable::Channel
  def self.notify!(discussion, iteration)
    broadcast_to("#{discussion.id}_#{iteration.id}", {})
  end

  def subscribed
    discussion = Solution::MentorDiscussion.find(params[:discussion_id])
    iteration = discussion.solution.iterations.find(params[:iteration_id])

    return unless current_user == discussion.mentor || current_user == discussion.student

    stream_for "#{discussion.id}_#{iteration.id}"
  end
end

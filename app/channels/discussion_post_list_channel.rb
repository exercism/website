class DiscussionPostListChannel < ApplicationCable::Channel
  def self.notify!(discussion)
    broadcast_to(discussion, {})
  end

  def subscribed
    discussion = Mentor::Discussion.find_by!(uuid: params[:discussion_id])

    return unless discussion.viewable_by?(current_user)

    stream_for(discussion)
  end
end

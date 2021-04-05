class ReputationChannel < ApplicationCable::Channel
  def self.broadcast_changed!(user)
    ReputationChannel.broadcast_to(user, { type: "reputation.changed" })
  end

  def subscribed
    stream_for current_user
  end

  def unsubscribed; end
end

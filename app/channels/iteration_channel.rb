class IterationChannel < ApplicationCable::Channel
  def subscribed
    stream_from CHANNEL_NAME
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(iteration)
    ActionCable.server.broadcast CHANNEL_NAME, iteration: iteration.serialized
  end

  CHANNEL_NAME = "iteration".freeze
end

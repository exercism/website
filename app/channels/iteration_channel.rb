class IterationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "iteration"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(iteration)
    ActionCable.server.broadcast "iteration", iteration: iteration.serialized
  end
end

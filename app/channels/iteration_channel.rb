class IterationChannel < ApplicationCable::Channel
  def subscribed
    iteration = current_user.iterations.find(params[:id])

    stream_for iteration
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(iteration)
    broadcast_to iteration, iteration: SerializeIteration.(iteration)
  end
end

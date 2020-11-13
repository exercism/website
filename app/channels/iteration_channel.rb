class IterationChannel < ApplicationCable::Channel
  def subscribed
    # Assert that the user owns this iteration
    iteration = current_user.iterations.find_by!(uuid: params[:uuid])

    # Don't use persisted objects for stream_for
    stream_for iteration.id
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(iteration)
    broadcast_to iteration.id, iteration: SerializeIteration.(iteration)
  end
end

class IterationChannel < ApplicationCable::Channel
  class UnauthorizedConnectionError < RuntimeError
  end

  def subscribed
    # Assert that the user owns this iteration
    iteration = Iteration.find_by!(uuid: params[:uuid])

    raise UnauthorizedConnectionError unless iteration.viewable_by?(current_user)

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

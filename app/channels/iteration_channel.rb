class IterationChannel < ApplicationCable::Channel
  def subscribed
    iteration = current_user.iterations.find(params[:iteration_id])
    stream_for iteration
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

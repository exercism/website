class IterationsChannel < ApplicationCable::Channel
  def subscribed
    solution = current_user.solutions.find(params[:solution_id])
    stream_for solution
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

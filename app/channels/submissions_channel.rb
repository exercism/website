class SubmissionsChannel < ApplicationCable::Channel
  def subscribed
    # Assert that the user owns this solution
    solution = current_user.solutions.find(params[:solution_id])

    # Don't use persisted objects for stream_for
    stream_for solution.id
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(solution)
    broadcast_to solution.id, submissions: solution.serialized_submissions
  end
end

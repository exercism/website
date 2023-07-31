class LatestIterationStatusChannel < ApplicationCable::Channel
  def subscribed
    solution = current_user.submissions.find_by!(uuid: params[:uuid])

    stream_from "latest_iteration_status:#{solution.uuid}"
  end

  def unsubscribed; end

  def self.broadcast!(solution)
    return if solution.latest_iteration.blank?

    ActionCable.server.broadcast(
      "latest_iteration_status:#{solution.uuid}",
      { status: solution.latest_iteration.status.to_s }
    )
  end
end

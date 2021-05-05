class LatestIterationStatusChannel < ApplicationCable::Channel
  def subscribed
    solution = Solution.find_by!(uuid: params[:id])

    stream_from "latest_iteration_status:#{solution.uuid}"
  end

  def unsubscribed; end

  def self.broadcast!(solution)
    return if solution.latest_iteration.blank?

    ActionCable.server.broadcast(
      "latest_iteration_status:#{solution.uuid}",
      status: solution.latest_iteration.status.to_s
    )
  end
end

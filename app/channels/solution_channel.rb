class SolutionChannel < ApplicationCable::Channel
  def subscribed
    solution = Solution.find_by!(uuid: params[:uuid])

    stream_for solution
  end

  def unsubscribed; end

  def self.broadcast!(solution)
    broadcast_to solution,
      solution: SerializeSolution.(solution),
      iterations: solution.iterations.map { |iteration| SerializeIteration.(iteration, sideload: [:automated_feedback]) }
  end
end

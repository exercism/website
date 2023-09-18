class SolutionWithLatestIterationChannel < ApplicationCable::Channel
  def subscribed
    solution = Solution.find_by!(uuid: params[:uuid])

    stream_for solution
  end

  def unsubscribed; end

  def self.broadcast!(solution)
    broadcast_to solution,
      solution: SerializeSolution.(solution),
      iteration: SerializeIteration.(solution.iterations.includes(:track, :exercise, :files, :submission).last,
        sideload: [:automated_feedback])
  end
end

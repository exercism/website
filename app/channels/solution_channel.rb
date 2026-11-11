class SolutionChannel < ApplicationCable::Channel
  def subscribed
    solution = Solution.find_by!(uuid: params[:uuid])

    # The student's iterations page uses this channel to update iterations as they are processed.
    unless solution.viewable_by?(current_user)
      reject
      return
    end

    stream_for solution
  end

  def unsubscribed; end

  def self.broadcast!(solution)
    broadcast_to solution, {
      solution: SerializeSolution.(solution),
      iterations: SerializeIterations.(solution.iterations, sideload: [:automated_feedback])
    }
  end
end

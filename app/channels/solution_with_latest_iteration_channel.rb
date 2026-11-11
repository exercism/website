class SolutionWithLatestIterationChannel < ApplicationCable::Channel
  def subscribed
    solution = Solution.find_by!(uuid: params[:uuid])

    # The editor's feedback modal and the mentoring session (for both the student and the mentor)
    # use this channel to show the latest iteration.
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
      iteration: SerializeIteration.(solution.iterations.includes(:track, :exercise, :files, :submission).last,
        sideload: [:automated_feedback])
    }
  end
end

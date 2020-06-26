class PagesController < ApplicationController
  def index
    solution = Solution.first
    IterationsChannel.broadcast_to solution, iterations: solution.iterations.map{|i|
      {
        id: i.id,
        time: Time.current.to_f
      }
    }
  end
end

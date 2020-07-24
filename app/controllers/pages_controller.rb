class PagesController < ApplicationController
  def index
<<<<<<< HEAD
    # solution = Solution.first
    # IterationsChannel.broadcast!(solution)
=======
    solution = Solution.last

    IterationsChannel.broadcast!(solution)
    IterationChannel.broadcast!(solution.iterations.last)
>>>>>>> Add iterations page
  end
end

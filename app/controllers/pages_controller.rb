class PagesController < ApplicationController
  def index
    solution = Solution.first
    IterationsChannel.broadcast!(solution)
  end
end

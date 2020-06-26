class Test::Components::IterationsSummaryTableController < ApplicationController
  def index
    @solution = Solution.find(params[:id])
  end
end

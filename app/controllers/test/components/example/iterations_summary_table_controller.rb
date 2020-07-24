class Test::Components::Example::IterationsSummaryTableController < ApplicationController
  def index
    @solution = Solution.find(params[:id])
  end
end

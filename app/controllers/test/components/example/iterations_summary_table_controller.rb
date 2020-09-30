class Test::Components::Example::IterationsSummaryTableController < Test::BaseController
  def index
    @solution = Solution.find(params[:id])
  end
end

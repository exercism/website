class Test::Components::Example::SubmissionsSummaryTableController < Test::BaseController
  def index
    @solution = Solution.find(params[:id])
  end
end

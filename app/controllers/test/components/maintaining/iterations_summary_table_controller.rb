class Test::Components::Maintaining::IterationsSummaryTableController < Test::BaseController
  def index
    @iterations = Iteration.order(created_at: :desc).take(50)
  end
end

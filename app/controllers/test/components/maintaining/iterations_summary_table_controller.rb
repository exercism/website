class Test::Components::Maintaining::IterationsSummaryTableController < ApplicationController
  def index
    @iterations = Iteration.order(created_at: :desc).take(50)
  end
end

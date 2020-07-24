class Maintaining::IterationsSummaryTableController < ApplicationController
  def index
    @iterations = Iteration.order(created_at: :desc).take(NUMBER_OF_ITERATIONS)
  end

  private
  NUMBER_OF_ITERATIONS = 50.freeze
end

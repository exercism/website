class Tracks::IterationsController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution

  def index
    @iterations = @solution.iterations.order(id: :desc) if @solution
  end
end

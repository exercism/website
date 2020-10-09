class SolutionsController < ApplicationController
  before_action :use_solution, only: [:edit]

  def edit; end

  private
  def use_solution
    @solution = current_user.solutions.find_by!(uuid: params[:id])
    @exercise = @solution.exercise
    @track = @exercise.track
  end
end

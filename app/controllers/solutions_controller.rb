class SolutionsController < ApplicationController
  before_action :use_solution, except: :create

  def edit; end

  def use_solution
    @solution = current_user.solutions.find(params[:id])
    @exercise = @solution.exercise
    @track = @exercise.track
  end
end

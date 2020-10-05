class SolutionsController < ApplicationController
  before_action :use_solution, only: [:edit]

  def legacy_show
    solution = Solution.find_by!(uuid: params[:uuid])
    if user_logged_in? && solution.user_id == current_user.id
      redirect_to Exercism::Routes.private_solution_url(solution)
    elsif solution.published?
      redirect_to Exercism::Routes.published_solution_url(solution)
    else
      raise ActiveRecord::RecordNotFound # Simulate a 404
    end
  end

  def edit; end

  private
  def use_solution
    @solution = current_user.solutions.find_by!(uuid: params[:id])
    @exercise = @solution.exercise
    @track = @exercise.track
  end
end

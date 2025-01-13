class API::Bootcamp::SolutionsController < API::Bootcamp::BaseController
  before_action :use_solution

  def complete
    Bootcamp::Solution::Complete.(@solution)

    next_exercise = Bootcamp::SelectNextExercise.(current_user)

    render json: {
      next_exercise: SerializeBootcampExercise.(next_exercise)
    }, status: :ok
  end

  private
  def use_solution
    @solution = current_user.bootcamp_solutions.find_by!(uuid: params[:uuid])
  end

  def user_project
    Bootcamp::UserProject.find_by!(user: solution.user, project: solution.exercise.project)
  end
end

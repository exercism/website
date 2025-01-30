class API::Bootcamp::SolutionsController < API::Bootcamp::BaseController
  before_action :use_solution

  def complete
    old_level_idx = current_user.bootcamp_data.level_idx
    Bootcamp::Solution::Complete.(@solution)
    new_level_idx = current_user.bootcamp_data.reload.level_idx

    # If we're on the same level still, find the next exercise
    # Otherwise we'll tell the student they've completed the level
    if old_level_idx == new_level_idx
      next_exercise = Bootcamp::SelectNextExercise.(current_user)
    else
      completed_level_idx = old_level_idx
      next_level_idx = new_level_idx if Bootcamp::Level.where(idx: new_level_idx).exists?
    end

    render json: {
      completed_level_idx:,
      next_level_idx:,
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

class API::Bootcamp::SolutionsController < API::Bootcamp::BaseController
  before_action :use_solution

  def complete
    old_level_idx = current_user.bootcamp_data.level_idx
    Bootcamp::Solution::Complete.(@solution)
    new_level_idx = current_user.bootcamp_data.reload.level_idx
    next_exercise = Bootcamp::SelectNextExercise.(current_user)

    # If they've moved forward, add the completed/new levels to the data
    if old_level_idx != new_level_idx
      completed_level_idx = old_level_idx
      next_level_idx = Bootcamp::Settings.level_idx >= new_level_idx ? new_level_idx : nil
    end

    render json: {
      next_exercise: SerializeBootcampExercise.(next_exercise),
      completed_level_idx:,
      next_level_idx:
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

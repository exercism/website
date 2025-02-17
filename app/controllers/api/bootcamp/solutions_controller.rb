class API::Bootcamp::SolutionsController < API::Bootcamp::BaseController
  before_action :use_solution

  def complete
    old_level_idx = current_user.bootcamp_data.level_idx
    Bootcamp::Solution::Complete.(@solution)
    new_level_idx = current_user.bootcamp_data.reload.level_idx

    if new_level_idx.nil? || old_level_idx == new_level_idx
      # If we've completed all the levels, or we're on the
      # same level still, find the next exercise.
      next_exercise = Bootcamp::SelectNextExercise.(current_user)
    end

    # If they've moved forward, add those two things to the data
    if old_level_idx != new_level_idx
      completed_level_idx = old_level_idx
      next_level_idx = Bootcamp::Settings.level_idx >= new_level_idx ? new_level_idx : nil
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

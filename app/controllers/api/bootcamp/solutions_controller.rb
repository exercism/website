class API::Bootcamp::SolutionsController < API::Bootcamp::BaseController
  before_action :use_solution

  def complete
    Bootcamp::Solution::Complete.(@solution)

    level_idx = @solution.exercise.level_idx
    num_level_exercises = @solution.exercise.level.exercises.count
    num_level_solutions = current_user.bootcamp_solutions.completed.
      joins(:exercise).where('bootcamp_exercises.level_idx': level_idx).
      count

    if num_level_exercises == num_level_solutions
      completed_level_idx = level_idx
    else
      next_exercise = Bootcamp::SelectNextExercise.(current_user)
    end

    render json: {
      completed_level_idx:,
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

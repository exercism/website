class Bootcamp::ExercisesController < Bootcamp::BaseController
  before_action :use_project, only: %i[show edit]
  before_action :use_exercise, only: %i[show edit]

  def index
    @projects = Bootcamp::Project.all.index_with { |p| p.exercises.unlocked }
    @solutions = current_user.bootcamp_solutions.where(exercise: @exercises).index_by(&:exercise_id)
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @solution = Bootcamp::Solution::Create.(current_user, @exercise)
  rescue ExerciseLockedError
    redirect_to action: :show
  end

  def use_exercise
    @exercise = @project.exercises.find_by!(slug: params[:slug])
  end
end

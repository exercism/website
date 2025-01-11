class Bootcamp::LevelsController < Bootcamp::BaseController
  def index
    @levels = Bootcamp::Level.all.index_by(&:idx)
  end

  def show
    @level = Bootcamp::Level.find_by!(idx: params[:idx])

    redirect_to action: :index if @level.locked?

    num_exercises = Bootcamp::Exercise.where(level: @level).count
    num_completed_solutions = current_user.bootcamp_solutions.completed.
      where(exercise: @level.exercises).count
    @completed = num_exercises == num_completed_solutions
  end
end

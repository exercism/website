class Bootcamp::DashboardController < Bootcamp::BaseController
  def index
    @exercise = Bootcamp::SelectNextExercise.(current_user)
    @solution = current_user.bootcamp_solutions.find_by(exercise: @exercise)

    level_idx = [Bootcamp::Settings.level_idx, current_user.bootcamp_data.level_idx].min
    level_idx = 1 if level_idx.zero?
    @level = Bootcamp::Level.find_by!(idx: level_idx)
  end
end

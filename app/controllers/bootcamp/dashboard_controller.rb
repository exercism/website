class Bootcamp::DashboardController < Bootcamp::BaseController
  def index
    @exercise = Bootcamp::SelectNextExercise.(current_user)
    @solution = current_user.bootcamp_solutions.find_by(exercise: @exercise)
    @level = Bootcamp::Level.find_by!(idx: 1)
  end
end

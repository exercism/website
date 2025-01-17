class Bootcamp::Admin::ExercisesController < Bootcamp::Admin::BaseController
  def index
    @projects_with_exercises = Bootcamp::Exercise.includes(:project).group_by(&:project)
    @in_progress_exercise_counts = Bootcamp::Solution.in_progress.group(:exercise_id).count
    @completed_exercise_counts = Bootcamp::Solution.completed.group(:exercise_id).count
    @current_level_idx = Bootcamp::Settings.instance.level_idx
  end
end

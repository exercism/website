class Bootcamp::Admin::ExercisesController < Bootcamp::Admin::BaseController
  def index
    @exercises_by_level = Bootcamp::Exercise.order(:idx).includes(:project).group_by(&:level_idx)
    in_progress = Bootcamp::Solution.in_progress
    threshold = Time.current - 10.days
    @active_exercise_counts = in_progress.where('updated_at >= ?', threshold).group(:exercise_id).count
    @stale_exercise_counts = in_progress.where('updated_at < ?', threshold).group(:exercise_id).count

    @completed_exercise_counts = Bootcamp::Solution.completed.group(:exercise_id).count
    @current_level_idx = Bootcamp::Settings.instance.level_idx
  end
end

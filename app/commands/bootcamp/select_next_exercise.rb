class Bootcamp::SelectNextExercise
  include Mandate

  initialize_with :user

  def call
    Bootcamp::Exercise.unlocked.
      where.not(id: completed_exercise_ids).
      where(level_idx:).
      first
  end

  private
  memoize
  def completed_exercise_ids
    user.bootcamp_solutions.completed.select(:exercise_id)
  end

  def level_idx
    user.bootcamp_data.active_part == 1 ? 1..10 : 11..100
  end
end

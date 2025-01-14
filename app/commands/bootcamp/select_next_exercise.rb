class Bootcamp::SelectNextExercise
  include Mandate

  initialize_with :user

  def call
    Bootcamp::Exercise.unlocked.
      where.not(id: completed_exercise_ids).first
  end

  private
  memoize
  def completed_exercise_ids
    user.bootcamp_solutions.completed.select(:exercise_id)
  end
end

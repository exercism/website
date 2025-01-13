class Bootcamp::Exercise::AvailableForUser
  include Mandate

  initialize_with :exercise, :user

  def call
    # If the exercise is gloabally locked, it's locked
    return false if exercise.locked?

    # The first exercise is always available
    return true if exercise.idx == 1

    # Otherwise the previous solution must be completed
    previous_exercises_completed?
  end

  private
  delegate :project, to: :exercise

  def previous_exercises_completed?
    previous_exercises = project.exercises.to_a.select do |prev_ex|
      prev_ex.level <= exercise.level ||
        (prev_ex.level == exercise.level && prev_ex.idx < exercise.idx)
    end

    completed_exercise_ids = user.bootcamp_solutions.completed.where(exercise_id: exercises.map(&:id)).pluck(:exercise_id)
    previous_exercises.all? { |ex| completed_exercise_ids.include?(ex.id) }
  end
end

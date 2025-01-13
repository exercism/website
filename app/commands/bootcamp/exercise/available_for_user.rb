class Bootcamp::Exercise::AvailableForUser
  include Mandate

  initialize_with :exercise, :user

  def call
    # If the exercise is gloabally locked, it's locked
    return false if exercise.locked?

    # Otherwise the previous solution must be completed
    previous_exercises_completed?
  end

  private
  delegate :project, to: :exercise

  def previous_exercises_completed?
    previous_exercises = project.exercises.where.not(id: exercise.id).select do |prev_ex|
      prev_ex.level_idx <= exercise.level_idx ||
        (prev_ex.level_idx == exercise.level_idx && prev_ex.idx < exercise.idx)
    end

    completed_exercise_ids = user.bootcamp_solutions.completed.where(exercise_id: previous_exercises.map(&:id)).pluck(:exercise_id)

    previous_exercises.all? { |ex| completed_exercise_ids.include?(ex.id) }
  end
end

class Bootcamp::Exercise::AvailableForUser
  include Mandate

  initialize_with :exercise, :user

  def call
    # If the exercise is gloabally locked, it's locked
    return false if exercise.locked?

    return false if user_level_idx < exercise.level_idx

    # Otherwise the previous solution must be completed
    previous_exercises_completed?
  end

  private
  delegate :project, to: :exercise

  def previous_exercises_completed?
    previous_exercises = project.exercises.
      where('bootcamp_exercises.level_idx': exercise_level_range).
      where('bootcamp_exercises.blocks_project_progression': true).
      where.not(id: exercise.id).select do |prev_ex|
      prev_ex.level_idx < exercise.level_idx ||
        (prev_ex.level_idx == exercise.level_idx && prev_ex.idx < exercise.idx)
    end

    completed_exercise_ids = user.bootcamp_solutions.completed.where(exercise_id: previous_exercises.map(&:id)).pluck(:exercise_id)

    previous_exercises.all? { |ex| completed_exercise_ids.include?(ex.id) }
  end

  def user_level_idx
    part = exercise.level_idx <= 10 ? 1 : 2
    part == 1 ? bootcamp_data.part_1_level_idx : bootcamp_data.part_2_level_idx
  end

  def exercise_level_range
    exercise.level_idx <= 10 ? 1..10 : 11..20
  end

  delegate :bootcamp_data, to: :user
end

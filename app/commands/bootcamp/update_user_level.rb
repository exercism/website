class Bootcamp::UpdateUserLevel
  include Mandate

  initialize_with :user

  def call
    # Users can't go backwards!
    return if user.bootcamp_data.level_idx >= new_level_idx

    user.bootcamp_data.update!(level_idx: new_level_idx)
  end

  memoize
  def new_level_idx
    max = 0
    exercise_ids_by_level_idx.each do |level_idx, exercise_ids|
      next if level_idx < max
      break unless solved_exercise_ids_by_level_idx[level_idx] == exercise_ids

      max = level_idx
    end
    max + 1
  end

  memoize
  def exercise_ids_by_level_idx
    Bootcamp::Exercise.where(blocks_level_progression: true).
      pluck(:level_idx, :id).
      group_by(&:first).
      transform_values { |v| v.map(&:last).sort }.
      sort.to_h
  end

  def solved_exercise_ids_by_level_idx
    user.bootcamp_solutions.completed.joins(:exercise).
      where('bootcamp_exercises.blocks_level_progression': true).
      pluck(:level_idx, :exercise_id).
      group_by(&:first).
      transform_values { |v| v.map(&:last).sort }
  end
end

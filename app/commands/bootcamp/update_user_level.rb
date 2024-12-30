class Bootcamp::UpdateUserLevel
  include Mandate

  initialize_with :user

  def call
    max = 0
    exercise_ids_by_level_idx.each do |level_idx, exercise_ids|
      next if level_idx < max
      break unless solved_exercise_ids_by_level_idx[level_idx] == exercise_ids

      max = level_idx
    end
    user.bootcamp_data.update!(level_idx: max)
  end

  memoize
  def exercise_ids_by_level_idx
    Bootcamp::Exercise.pluck(:level_idx, :id).
      group_by(&:first).
      transform_values { |v| v.map(&:last) }.
      sort.to_h
  end

  def solved_exercise_ids_by_level_idx
    user.bootcamp_solutions.completed.joins(:exercise).pluck(:level_idx, :exercise_id).
      group_by(&:first).
      transform_values { |v| v.map(&:last) }
  end
end

class Bootcamp::UpdateUserLevel
  include Mandate

  initialize_with :user, :part

  def call
    # Users can't go backwards!
    return if current_level_idx >= new_level_idx

    field = part == 1 ? :part_1_level_idx : :part_2_level_idx
    bootcamp_data.update!(field => new_level_idx)
  end

  memoize
  def new_level_idx
    max = part == 1 ? 0 : 10
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
      where(level_idx: part == 1 ? 1..10 : 11..100).
      pluck(:level_idx, :id).
      group_by(&:first).
      transform_values { |v| v.map(&:last).sort }.
      sort.to_h
  end

  def solved_exercise_ids_by_level_idx
    user.bootcamp_solutions.completed.joins(:exercise).
      where('bootcamp_exercises.blocks_level_progression': true).
      where('bootcamp_exercises.level_idx': part == 1 ? 1..10 : 11..100).
      pluck(:level_idx, :exercise_id).
      group_by(&:first).
      transform_values { |v| v.map(&:last).sort }
  end

  def current_level_idx
    part == 1 ? bootcamp_data.part_1_level_idx : bootcamp_data.part_2_level_idx
  end

  delegate :bootcamp_data, to: :user
end

class Exercise::Search
  include Mandate

  initialize_with :user_track, criteria: nil

  def call
    @exercises = user_track.exercises
    filter_criteria!
    sort!
    @exercises
  end

  private
  def filter_criteria!
    return if criteria.blank?

    criteria.strip.split(" ").each do |crit|
      @exercises = @exercises.where("exercises.title LIKE ?", "%#{crit}%").
        or(@exercises.where("exercises.slug LIKE ?", "%#{crit}%"))
    end
  end

  def sort!
    @exercises = @exercises.order(:position).to_a

    return if user_track.external?

    mapping = %i[
      iterated started
      available
      completed published
      locked
    ]

    @exercises.sort_by! do |exercise|
      status = user_track.exercise_status(exercise).to_sym
      status_modifier = mapping.index(status)
      type_modifier = exercise.concept_exercise? ? 0 : 1

      "#{status_modifier}#{type_modifier}#{exercise.position.to_s.rjust(5, '0')}".to_i
    end
  end
end

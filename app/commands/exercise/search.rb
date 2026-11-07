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

    if I18n.locale == I18n.default_locale
      filter_criteria_in_sql!
    else
      filter_criteria_with_translations!
    end
  end

  def filter_criteria_in_sql!
    words.each do |word|
      @exercises = @exercises.where("exercises.title LIKE ?", "%#{word}%").
        or(@exercises.where("exercises.slug LIKE ?", "%#{word}%"))
    end
  end

  # Translated titles are not in the database, so in another locale each
  # exercise is matched in Ruby against its English title, its slug and its
  # translated title. A track has at most a few hundred exercises.
  def filter_criteria_with_translations!
    downcased_words = words.map(&:downcase)

    ids = @exercises.select do |exercise|
      haystacks = [exercise.read_attribute(:title), exercise.slug, exercise.title].compact.map(&:downcase)
      downcased_words.all? { |word| haystacks.any? { |haystack| haystack.include?(word) } }
    end.map(&:id)

    @exercises = @exercises.where(id: ids)
  end

  def words = criteria.strip.split(" ")

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

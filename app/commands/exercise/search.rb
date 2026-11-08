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

    criteria.strip.split(" ").each do |word|
      matches = @exercises.where("exercises.slug LIKE ?", "%#{word}%")
      if I18n.locale == I18n.default_locale
        matches = matches.or(@exercises.where("exercises.title LIKE ?", "%#{word}%"))
      else
        matches = matches.or(@exercises.where(slug: translated_slugs_matching(word)))
      end
      @exercises = matches
    end
  end

  # Translated names are not in the database. The track's metadata catalog
  # holds them as "exercise:<slug>:name", so the matching slugs come from it.
  def translated_slugs_matching(word)
    word = word.downcase
    translated_names.filter_map { |slug, name| slug if name.downcase.include?(word) }
  end

  memoize
  def translated_names
    repo_name = user_track.track.translation_metadata_repo_name
    TranslationRepo.metadata(I18n.locale, repo_name).filter_map do |unit_id, text|
      match = unit_id.match(/\Aexercise:(.+):name\z/)
      [match[1], text] if match && text.is_a?(String)
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

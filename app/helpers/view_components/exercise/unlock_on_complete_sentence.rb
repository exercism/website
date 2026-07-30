module ViewComponents
  class Exercise::UnlockOnCompleteSentence < ViewComponent
    initialize_with :exercise, :user_track

    I18N_PREFIX = "components.exercise.unlock_on_complete_sentence".freeze

    def to_s
      return unless exercise.concept_exercise?
      return if num_unlockable_exercises.zero?

      unlockable_concept_names.present? ? with_concepts_sentence : without_concepts_sentence
    end

    private
    def with_concepts_sentence
      I18n.t(
        "#{I18N_PREFIX}.with_concepts_html",
        exercise_title: exercise.title,
        concepts: I18n.t("#{I18N_PREFIX}.concept_count", count: unlockable_concept_names.size),
        concept_names: unlockable_concept_names.to_sentence,
        exercises: exercises_text
      )
    end

    def without_concepts_sentence
      I18n.t("#{I18N_PREFIX}.without_concepts_html", exercise_title: exercise.title, exercises: exercises_text)
    end

    def exercises_text
      I18n.t("#{I18N_PREFIX}.exercise_count", count: num_unlockable_exercises)
    end

    memoize
    def num_unlockable_exercises
      user_track.unlockable_exercises_for_exercise(exercise).count
    end

    memoize
    def unlockable_concept_names
      user_track.unlockable_concepts_for_exercise(exercise).pluck(:name)
    end
  end
end

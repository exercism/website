module ViewComponents
  class Exercise::UnlockOnCompleteSentence < ViewComponent
    initialize_with :exercise, :user_track

    def to_s
      return unless exercise.concept_exercise?
      return if num_unlockable_exercises.zero?

      t = "By marking #{exercise.title} as complete, you’ll unlock "

      if unlockable_concept_names.present?
        t << "#{pluralize unlockable_concept_names.size, 'concept'} "
        t << "(#{unlockable_concept_names.to_sentence}) and "
      end

      t + "#{pluralize num_unlockable_exercises, 'new exercise'}."
    end

    private
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

module ViewComponents
  class Exercise::UnlockOnCompleteSentence < ViewComponent
    initialize_with :exercise, :user_track

    def to_s
      return unless exercise.concept_exercise?
      return if num_unlocked_exercises.zero?

      tag.div(class: "text-14 leading-160 mt-12") do
        t = "By marking #{exercise.title} as complete, you’ll unlock "

        if unlocked_concept_names.present?
          t << "#{pluralize unlocked_concept_names.size, 'concept'} "
          t << "(#{unlocked_concept_names.to_sentence}) and "
        end

        t + "#{pluralize num_unlocked_exercises, 'new exercise'}."
      end
    end

    private
    memoize
    def num_unlocked_exercises
      user_track.unlocked_exercises_for_exercise(exercise).count
    end

    memoize
    def unlocked_concept_names
      user_track.unlocked_concepts_for_exercise(exercise).pluck(:name)
    end
  end
end

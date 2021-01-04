module ViewComponents
  class ConceptProgressBar < ViewComponent
    extend Mandate::Memoize
    def initialize(concept, user_track, view_context: nil)
      super()

      @concept = concept
      @user_track = user_track
      @view_context = view_context
    end

    def to_s
      classes = ["c-concept-progress-bar"]
      classes << "--completed" if user_track.concept_mastered?(concept)

      tag.progress(
        class: classes.join(" "),
        value: user_track.num_completed_exercises_for_concept(concept),
        max: user_track.num_exercises_for_concept(concept)
      )
    end

    private
    attr_reader :concept, :user_track, :size
  end
end

module ViewComponents
  class ConceptProgressBar < ViewComponent
    extend Mandate::Memoize
    def initialize(concept, user_track, view_context: nil)
      @concept = concept
      @user_track = user_track
      @view_context = view_context
    end

    def to_s
      classes = ["c-concept-progress-bar"]
      classes << "--completed" if concept_summary.mastered?

      tag.progress(
        class: classes.join(" "),
        value: concept_summary.num_completed_exercises,
        max: concept_summary.num_exercises
      )
    end

    private
    attr_reader :concept, :user_track, :size

    memoize
    def concept_summary
      user_track.summary.concept(concept.slug)
    end
  end
end

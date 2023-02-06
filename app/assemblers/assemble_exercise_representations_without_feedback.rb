class AssembleExerciseRepresentationsWithoutFeedback
  include Mandate

  def self.keys = %i[page order criteria track_slug only_mentored_solutions]

  initialize_with :mentor, :params

  def call
    SerializePaginatedCollection.(
      representations,
      serializer: SerializeExerciseRepresentations,
      serializer_kwargs: { params: },
      meta: {
        unscoped_total: 0 # TODO: fix performance
        # unscoped_total: Exercise::Representation.without_feedback.count
      }
    )
  end

  private
  memoize
  def representations
    Exercise::Representation::Search.(
      mentor:,
      track:,
      with_feedback: false,
      only_mentored_solutions: params[:only_mentored_solutions],
      criteria: params[:criteria],
      page: params.fetch(:page, 1),
      order: params.fetch(:order, :most_submissions)
    )
  end

  def track
    return if params[:track_slug].blank?

    Track.find(params[:track_slug])
  end
end

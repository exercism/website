class AssembleExerciseRepresentationsWithoutFeedback
  include Mandate

  initialize_with :user, :params

  def self.keys = %i[page order criteria track_slug]

  def call
    SerializePaginatedCollection.(
      representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: Exercise::Representation.without_feedback.count
      }
    )
  end

  private
  memoize
  def representations
    Exercise::Representation::Search.(
      user:,
      track:,
      status: :without_feedback,
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

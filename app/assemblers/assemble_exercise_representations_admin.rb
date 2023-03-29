class AssembleExerciseRepresentationsAdmin
  include Mandate

  def self.keys = %i[page order criteria track_slug]

  initialize_with :params

  def call
    SerializePaginatedCollection.(
      representations,
      serializer: SerializeExerciseRepresentations,
      serializer_kwargs: { params: },
      meta: {
        unscoped_total: Exercise::Representation.with_feedback.count
      }
    )
  end

  private
  memoize
  def representations
    Exercise::Representation::Search.(
      track:,
      with_feedback: true,
      criteria: params[:criteria],
      page: params.fetch(:page, 1),
      order: params.fetch(:order, :most_submissions)
    )
  end

  def track = Track.find(params[:track_slug])
end

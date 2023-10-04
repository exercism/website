class AssembleExerciseRepresentationsAdmin
  include Mandate

  def self.keys = %i[page order criteria track_slug only_mentored_solutions]

  initialize_with :mentor, :params

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
      mode: :admin,
      representer_version:,
      track:,
      mentor:,
      only_mentored_solutions: params[:only_mentored_solutions],
      criteria: params[:criteria],
      page: params.fetch(:page, 1),
      order: params.fetch(:order, :most_recent_feedback)
    )
  end

  def track = Track.find_by(slug: params[:track_slug])
  def representer_version = track.representations.maximum(:representer_version) || 1
end

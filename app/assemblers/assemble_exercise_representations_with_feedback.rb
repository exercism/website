class AssembleExerciseRepresentationsWithFeedback
  include Mandate

  def self.keys = %i[page order criteria track_slug]

  initialize_with :mentor, :params

  def call
    SerializePaginatedCollection.(
      representations,
      serializer: SerializeExerciseRepresentations,
      serializer_kwargs: { params: },
      meta: {
        unscoped_total: Exercise::Representation.with_feedback_by(mentor).count
      }
    )
  end

  private
  memoize
  def representations
    Exercise::Representation::Search.(
      mode: :with_feedback,
      representer_version:,
      track:,
      mentor:,
      criteria: params[:criteria],
      page: params.fetch(:page, 1),
      order: params.fetch(:order, :most_submissions)
    )
  end

  def representer_version = track.representations.maximum(:representer_version) || 1

  memoize
  def track
    Track.find_by(slug: params[:track_slug]) ||
      mentor.track_mentorships.automator.first.track
  end
end

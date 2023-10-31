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
      mode: :without_feedback,
      representer_version:,
      track:,
      mentor:,
      only_mentored_solutions: params[:only_mentored_solutions],
      criteria: params[:criteria],
      page: params.fetch(:page, 1),
      order: params.fetch(:order, :most_submissions)
    )
  end

  def representer_version = track.representations.maximum(:representer_version) || 1

  memoize
  def track
    t = Track.find_by(slug: params[:track_slug])
    return t if t

    return Track.first if mentor.staff?

    mentor.track_mentorships.automator.first.track
  end
end

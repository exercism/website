class AssembleExerciseRepresentationsWithoutFeedbackList
  include Mandate

  initialize_with :user, :params

  def self.keys = %i[page order criteria track_slug]

  def call
    SerializePaginatedCollection.(
      representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: Exercise::Representation.without_feedback.count,
        links: {
          self: Exercism::Routes.without_feedback_api_mentoring_representations_path,
          with_feedback: Exercism::Routes.with_feedback_api_mentoring_representations_path
        }
      }
    )
  end

  private
  memoize
  def representations
    Exercise::Representation::Search.(
      track:,
      status: :without_feedback,
      page: params[:page],
      order: params[:order],
      criteria: params[:criteria]
    )
  end

  def track
    return user.mentored_tracks if params[:track_slug].blank?

    Track.find(params[:track_slug])
  end
end

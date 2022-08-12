class AssembleExerciseRepresentationsWithoutFeedbackList
  include Mandate

  initialize_with :user, :params

  def self.keys = %i[page order criteria track]

  def call
    SerializePaginatedCollection.(
      representations,
      serializer: SerializeExerciseRepresentation,
      meta: {
        unscoped_total: 0 # TODO: implement
      }
    )
  end

  memoize
  def representations
    Exercise::Representation::Search.(
      # TODO
      # exercise,
      # page: params[:page],
      # order: params[:order],
      # criteria: params[:criteria],
      # sync_status: params[:up_to_date].present? ? :up_to_date : nil,
      # tests_status: params[:passed_tests].present? ? :passed : nil,
      # head_tests_status: params[:not_passed_head_tests].present? ? nil : %i[not_queued queued passed]
    )
  end

  memoize
  delegate :mentored_tracks, to: :user
end

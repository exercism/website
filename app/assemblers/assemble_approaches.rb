class AssembleApproaches
  include Mandate

  initialize_with :params

  def call
    SerializePaginatedCollection.(
      approaches,
      serializer: SerializeApproaches,
      meta: {
        unscoped_total: Exercise::Approach.count
      }
    )
  end

  def approaches
    Exercise::Approach::Search.(
      exercise_slug: params[:exercise_slug],
      track_slug: params[:track_slug],
      order: params[:order],
      page: params[:page]
    )
  end
end

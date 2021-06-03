class AssembleMentorRequests
  include Mandate

  initialize_with :params, :current_user

  def call
    SerializePaginatedCollection.(
      requests,
      serializer: SerializeMentorRequests,
      serializer_args: current_user,
      meta: {
        unscoped_total: unscoped_total
      }
    )
  end

  memoize
  def unscoped_total
    ::Mentor::Request::Retrieve.(
      mentor: current_user,
      page: params[:page],
      track_slug: params[:track_slug],
      exercise_slug: params[:exercise_slug],
      sorted: false,
      paginated: false
    ).count
  end

  def requests
    ::Mentor::Request::Retrieve.(
      mentor: current_user,
      page: params[:page],
      criteria: params[:criteria],
      order: params[:order],
      track_slug: params[:track_slug],
      exercise_slug: params[:exercise_slug]
    )
  end
end

class AssembleContributors
  include Mandate

  initialize_with :params

  def call
    SerializePaginatedCollection.(
      users,
      serializer: SerializeContributors,
      serializer_kwargs: {
        starting_rank:,
        contextual_data:
      }
    )
  end

  memoize
  def starting_rank
    (users.limit_value * (users.current_page - 1)) + 1
  end

  memoize
  def track_id
    Track.find(params[:track_slug]).id if params[:track_slug].present?
  end

  memoize
  def users
    User::ReputationPeriod::Search.(
      period: params[:period],
      category: params[:category],
      track_id:,
      user_handle: params[:user_handle],
      page: params[:page]
    )
  end

  memoize
  def contextual_data
    User::ReputationToken::CalculateContextualData.(
      users.map(&:id),
      period: params[:period],
      category: params[:category],
      track_id:
    )
  end
end

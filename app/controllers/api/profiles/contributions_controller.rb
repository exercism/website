class API::Profiles::ContributionsController < API::Profiles::BaseController
  def building
    tokens = User::ReputationToken::Search.(
      @user,
      category: %i[building authoring],
      page: params[:page]
    )

    render json: SerializePaginatedCollection.(
      tokens,
      serializer: SerializeUserReputationTokens
    )
  end

  def maintaining
    tokens = User::ReputationToken::Search.(
      @user,
      category: :maintaining,
      page: params[:page]
    )

    render json: SerializePaginatedCollection.(
      tokens,
      serializer: SerializeUserReputationTokens
    )
  end

  def authoring
    exercises = User::RetrieveAuthoredAndContributedExercises.(
      @user,
      page: params[:page]
    )

    render json: SerializePaginatedCollection.(
      exercises,
      serializer: SerializeExerciseAuthorships
    )
  end

  def other
    tokens = User::ReputationToken::Search.(
      @user,
      category: :other,
      page: params[:page]
    )

    render json: SerializePaginatedCollection.(
      tokens,
      serializer: SerializeUserReputationTokens
    )
  end
end

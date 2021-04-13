module API::Profiles
  class ContributionsController < BaseController
    def building
      tokens = @user.reputation_tokens.
        where(category: %i[building authoring]).
        page(params[:page]).per(20)

      render json: SerializePaginatedCollection.(
        tokens,
        serializer: SerializeUserReputationTokens
      )
    end

    def maintaining
      tokens = @user.reputation_tokens.
        where(category: :maintaining).
        page(params[:page]).per(20)

      render json: SerializePaginatedCollection.(
        tokens,
        serializer: SerializeUserReputationTokens
      )
    end

    def authoring
      ids = @user.authored_exercises.select(:id) +
            @user.contributed_exercises.select(:id)

      exercises = Exercise.
        where(id: ids).
        order(id: :desc).
        page(params[:page]).per(20)

      render json: SerializePaginatedCollection.(
        exercises,
        serializer: SerializeExercises
      )
    end
  end
end

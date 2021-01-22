module API
  class ReputationController < BaseController
    def self.per
      25
    end

    def index
      tokens = User::ReputationToken::Search.(
        current_user,
        criteria: params[:criteria],
        category: params[:category]
      )

      render json: SerializePaginatedCollection.(tokens, SerializeReputationTokens)
    end
  end
end

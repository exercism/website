module API
  class ReputationController < BaseController
    def index
      tokens = User::ReputationToken::Search.(
        current_user,
        criteria: params[:criteria],
        category: params[:category]
      )

      tokens = tokens.page(params[:page] || 1).per(params[:per] || 25)

      render json: SerializePaginatedCollection.(tokens, SerializeReputationToken)
    end
  end
end

module API
  class ReputationController < BaseController
    def index
      tokens = User::ReputationToken::Search.(
        current_user,
        criteria: params[:criteria],
        category: params[:category]
      )

      render json: SerializePaginatedCollection.(
        tokens,
        data: tokens.map(&:rendering_data)
      )
    end

    def mark_as_seen
      current_user.reputation_tokens.where(
        uuid: params[:ids]
      ).update_all(seen: true)

      render json: {}
    end
  end
end

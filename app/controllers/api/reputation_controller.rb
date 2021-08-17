module API
  class ReputationController < BaseController
    def index
      render json: AssembleReputationTokens.(current_user, params)
    end

    def mark_as_seen
      token = current_user.reputation_tokens.find_by!(uuid: params[:uuid])
      token.seen!

      render json: { reputation: token.rendering_data }
    end

    def mark_all_as_seen
      User::ReputationToken::MarkAllAsSeen.(current_user)

      render json: {}
    end

    private
    def list_params
      params.permit(AssembleReputationTokens.keys)
    end
  end
end

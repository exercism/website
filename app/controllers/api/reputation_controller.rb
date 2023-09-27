class API::ReputationController < API::BaseController
  skip_before_action :ensure_onboarded!, only: [:index]

  def index
    render json: AssembleReputationTokens.(current_user, list_params)
  end

  def mark_as_seen
    token = current_user.reputation_tokens.find_by!(uuid: params[:uuid])
    User::ReputationToken::MarkAsSeen.(token)

    render json: { reputation: token.rendering_data }
  end

  def mark_all_as_seen
    User::ReputationToken::MarkAllAsSeen.(current_user)

    render json: AssembleReputationTokens.(current_user, {})
  end

  private
  def list_params
    params.permit(AssembleReputationTokens.keys)
  end
end

module API
  class ReputationController < BaseController
    def index
      tokens = User::ReputationToken::Search.(
        current_user,
        criteria: params[:criteria],
        category: params[:category],
        order: params[:order],
        per: params[:per_page],
        page: params[:page]
      )

      data = tokens.map do |token|
        token.rendering_data.merge(
          links: {
            mark_as_seen: Exercism::Routes.mark_as_seen_api_reputation_url(token.uuid)
          }
        )
      end

      render json: SerializePaginatedCollection.(
        tokens,
        data: data,
        meta: {
          links: {
            tokens: Exercism::Routes.reputation_journey_url
          },
          total_reputation: current_user.formatted_reputation,
          is_all_seen: current_user.reputation_tokens.unseen.empty?
        }
      )
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
  end
end

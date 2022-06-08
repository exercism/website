class AssembleReputationTokens
  include Mandate

  initialize_with :user, :params

  def self.keys
    %w[criteria category order per_page page]
  end

  def call
    data = tokens.map do |token|
      token.rendering_data.merge(
        links: {
          mark_as_seen: Exercism::Routes.mark_as_seen_api_reputation_url(token.uuid)
        }
      )
    end

    SerializePaginatedCollection.(
      tokens,
      data:,
      meta: {
        links: {
          tokens: Exercism::Routes.reputation_journey_url,
          mark_all_as_seen: Exercism::Routes.mark_all_as_seen_api_reputation_index_url
        },
        total_reputation: user.formatted_reputation,
        unseen_total: user.reputation_tokens.unseen.count
      }
    )
  end

  memoize
  def tokens
    User::ReputationToken::Search.(
      user,
      criteria: params[:criteria],
      category: params[:category],
      order: params[:order],
      per: params[:per_page],
      page: params[:page]
    )
  end
end

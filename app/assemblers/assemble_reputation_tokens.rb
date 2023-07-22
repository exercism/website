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

  private
  memoize
  def tokens
    params[:for_header] ? header_tokens : page_tokens
  end

  # This is much more efficient than the page_tokens version below
  def header_tokens
    ids = user.reputation_tokens.unseen.limit(5).pluck(:id)

    # TODO: This needs a desc index adding
    ids += user.reputation_tokens.seen.limit(5 - ids.length).
      where.not(id: ids).order(id: :desc).pluck(:id)

    tokens = User::ReputationToken.where(id: ids).
      sort_by { |s| ids.index(s.id) }
    Kaminari.paginate_array(tokens, total_count: tokens.size).page(1).per(5)
  end

  # This needs a descending index adding and performance testing against a major user
  def page_tokens
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

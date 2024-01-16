class AssembleReputationTokens
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[criteria category order per_page page for_header]
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
  # We want to order by unseed then seen but this is slow.
  # So we create a Set, populate it with the first five unseed,
  # then fill with the most recent first 5 (regardless of status).
  # Then we just look at the first 5 things in the set.
  def header_tokens
    ids = Set.new(user.reputation_tokens.unseen.order(id: :desc).limit(5).pluck(:id))

    # TODO: This needs a desc index adding
    ids += user.reputation_tokens.seen.limit(10).order(id: :desc).pluck(:id) unless ids.size == 5

    ids = ids.to_a # Sets don't have `.index`

    tokens = User::ReputationToken.where(id: ids).
      sort_by { |rt| ids.index(rt.id) }[0, 5]

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

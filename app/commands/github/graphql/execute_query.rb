class Github::Graphql::ExecuteQuery
  include Mandate

  initialize_with :query, :data_path

  def call
    end_cursor = nil
    results = []

    loop do
      body = { query:, variables: { endCursor: end_cursor } }
      response = Exercism.octokit_graphql_client.post("https://api.github.com/graphql", body.to_json).to_h

      data = response.dig(:data, *data_path)
      break results unless data

      results << data
      break results unless data.dig(:pageInfo, :hasNextPage)

      end_cursor = data.dig(:pageInfo, :endCursor)

      rate_limit = response.dig(:data, :rateLimit)
      handle_rate_limit(rate_limit) if rate_limit
    end
  end

  private
  def handle_rate_limit(rate_limit)
    # If the rate limit was exceeded, sleep until it resets
    return if rate_limit[:remaining].positive?

    reset_at = Time.parse(rate_limit[:resetAt]).utc
    seconds_until_reset = reset_at - Time.now.utc
    sleep(seconds_until_reset.ceil)
  end
end

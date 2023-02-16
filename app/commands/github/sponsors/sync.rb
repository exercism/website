class Github::Sponsors::Sync
  include Mandate

  def call
    sponsor_github_usernames.each do |github_username|
      ProcessGithubSponsorUpdateJob.perform_later('created', github_username)
    end
  end

  private
  memoize
  def sponsor_github_usernames
    end_cursor = nil
    github_usernames = []

    loop do
      body = { query: QUERY, variables: { endCursor: end_cursor } }
      response = Exercism.octokit_client.post("https://api.github.com/graphql", body.to_json).to_h

      sponsors = response.dig(:data, :organization, :sponsors)
      github_usernames += sponsors[:nodes].map { |node| node[:login] }

      break github_usernames unless sponsors[:pageInfo][:hasNextPage]

      end_cursor = sponsors[:pageInfo][:endCursor]
      handle_rate_limit(response[:data][:rateLimit])
    end
  end

  def handle_rate_limit(rate_limit)
    # If the rate limit was exceeded, sleep until it resets
    return if rate_limit[:remaining].positive?

    reset_at = Time.parse(rate_limit[:resetAt]).utc
    seconds_until_reset = reset_at - Time.now.utc
    sleep(seconds_until_reset.ceil)
  end

  QUERY = <<~QUERY.strip
    query ($endCursor: String) {
      organization(login: "exercism") {
        ... on Sponsorable {
          sponsors(first: 100, after: $endCursor) {
            nodes {
              ... on User {
                login
              }
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
      }
      rateLimit {
        remaining
        resetAt
      }
    }
  QUERY
  private_constant :QUERY
end

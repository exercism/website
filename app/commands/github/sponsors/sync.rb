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
    Github::Graphql::ExecuteQuery.(QUERY, %i[organization sponsors]).flat_map do |data|
      data[:nodes].map { |node| node[:login] }
    end
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

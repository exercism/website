class Github::PullRequest::SyncRepo
  include Mandate

  initialize_with :repo

  def call
    pull_requests.each do |pr|
      Github::PullRequest::CreateOrUpdate.(
        pr[:node_id],
        number: pr[:number],
        title: pr[:title],
        author_username: pr[:author_username],
        merged_by_username: pr[:merged_by_username],
        repo: pr[:repo],
        reviews: pr[:reviews],
        state: pr[:state].downcase.to_sym,
        data: pr
      )
    end
  end

  private
  memoize
  def pull_requests
    cursor = nil
    results = []

    loop do
      page_data = fetch_page(cursor)

      # TODO: (Optional) filter out PRs we want to ignore (e.g. the v3 bulk rename PRs)
      results += pull_requests_from_page_data(page_data)
      break results unless page_data.dig(:data, :repository, :pullRequests, :pageInfo, :hasNextPage)

      cursor = page_data.dig(:data, :repository, :pullRequests, :pageInfo, :endCursor)
      handle_rate_limit(page_data.dig(:data, :rateLimit))
    end
  end

  def fetch_page(cursor)
    query = <<~QUERY.strip
      query {
        repository(owner: "#{repo_owner}", name: "#{repo_name}") {
          nameWithOwner
          pullRequests(first: 100, #{%(, after: "#{cursor}") if cursor}) {
            nodes {
              id
              url
              title
              number
              createdAt
              closedAt
              state
              merged
              mergedAt
              mergedBy {
                login
              }
              labels(first: 100) {
                nodes {
                  name
                }
              }
              author {
                login
              }
              reviews(first: 100) {
                nodes {
                  id
                  submittedAt
                  author {
                    login
                  }
                }
              }
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
        rateLimit {
          remaining
          resetAt
        }
      }
    QUERY

    Exercism.octokit_graphql_client.post("https://api.github.com/graphql", { query: }.to_json).to_h
  end

  def pull_requests_from_page_data(response)
    # We're transforming the GraphQL response to the format used to call
    # User::ReputationToken::AwardForPullRequest that is called when the
    # pull request update webhook fires.
    # This allows us to work with pull requests using a single code path.
    response[:data][:repository][:pullRequests][:nodes].map do |pr|
      {
        action: pr[:state].casecmp?('open') ? 'opened' : 'closed',
        author_username: pr[:author].present? ? pr[:author][:login] : nil,
        url: "https://api.github.com/repos/#{response[:data][:repository][:nameWithOwner]}/pulls/#{pr[:number]}",
        html_url: pr[:url],
        labels: pr[:labels][:nodes].map { |node| node[:name] },
        state: pr[:state].downcase,
        node_id: pr[:id],
        number: pr[:number],
        title: pr[:title],
        repo: response[:data][:repository][:nameWithOwner],
        created_at: pr[:createdAt].present? ? Time.parse(pr[:createdAt]).utc : nil,
        closed_at: pr[:closedAt].present? ? Time.parse(pr[:closedAt]).utc : nil,
        merged: pr[:merged],
        merged_at: pr[:mergedAt].present? ? Time.parse(pr[:mergedAt]).utc : nil,
        merged_by_username: pr[:mergedBy].present? ? pr[:mergedBy][:login] : nil,
        reviews: pr[:reviews][:nodes].map do |node|
          {
            node_id: node[:id],
            submitted_at: node[:submittedAt].present? ? Time.parse(node[:submittedAt]).utc : nil,
            reviewer_username: node[:author].present? ? node[:author][:login] : nil
          }
        end
      }
    end
  end

  memoize
  def repo_owner
    repo.split('/').first
  end

  memoize
  def repo_name
    repo.split('/').second
  end

  def handle_rate_limit(rate_limit_data)
    # If the rate limit was exceeded, sleep until it resets
    return if rate_limit_data[:remaining].positive?

    reset_at = Time.parse(rate_limit_data[:resetAt]).utc
    seconds_until_reset = reset_at - Time.now.utc
    sleep(seconds_until_reset.ceil)
  end
end

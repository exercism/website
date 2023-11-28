class Github::Issue::SyncRepo
  include Mandate

  initialize_with :repo

  def call
    issues.each do |issue|
      Github::Issue::CreateOrUpdate.(
        issue[:node_id],
        number: issue[:number],
        title: issue[:title],
        state: issue[:state],
        repo: issue[:repo],
        labels: issue[:labels],
        opened_at: issue[:opened_at],
        opened_by_username: issue[:opened_by_username]
      )
    end
  end

  private
  memoize
  def issues
    cursor = nil
    results = []

    loop do
      page_data = fetch_page(cursor)

      results += issues_from_page_data(page_data)
      break results unless page_data.dig(:data, :repository, :issues, :pageInfo, :hasNextPage)

      cursor = page_data.dig(:data, :repository, :issues, :pageInfo, :endCursor)
      handle_rate_limit(page_data.dig(:data, :rateLimit))
    end
  end

  def fetch_page(cursor)
    query = <<~QUERY.strip
      {
        repository(owner: "#{repo_owner}", name: "#{repo_name}") {
          nameWithOwner
          issues(first: 100 #{%(, after: "#{cursor}") if cursor}) {
            nodes {
              id
              number
              title
              state
              createdAt
              author {
                login
              }
              labels(first: 100) {
                nodes {
                  name
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

  def issues_from_page_data(response)
    response[:data][:repository][:issues][:nodes].map do |issue|
      {
        node_id: issue[:id],
        number: issue[:number],
        title: issue[:title],
        state: issue[:state],
        repo: response[:data][:repository][:nameWithOwner],
        labels: issue[:labels][:nodes].map { |label| label[:name] },
        opened_at: issue[:createdAt].present? ? Time.parse(issue[:createdAt]).utc : nil,
        opened_by_username: issue[:author].present? ? issue[:author][:login] : nil
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

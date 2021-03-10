module Git
  class PullRequest
    class SyncRepo
      include Mandate

      initialize_with :repo

      def call
        pull_requests.each do |pr|
          Git::PullRequest::CreateOrUpdate.(pr[:pr_id],
            number: pr[:pr_number],
            author_github_username: pr[:author],
            repo: pr[:repo],
            data: pr,
            reviews: pr[:reviews])
        end
      end

      private
      memoize
      def pull_requests
        cursor = nil
        results = []

        loop do
          page_data = fetch_page(cursor)

          # TODO: filter out PRs we want to ignore (e.g. the v3 bulk rename PRs)
          results += pull_requests_from_page_data(page_data)

          break results unless pull_requests_data[:pageInfo][:hasNextPage]

          cursor = page_data[:data][:repository][:pullRequests][:pageInfo][:endCursor]

          handle_rate_limit(page_data[:data][:rateLimit])
        end
      end

      def fetch_page(cursor)
        query = <<~QUERY.strip
            repository(owner: "#{repo_owner}", name: "#{repo_name}") {
              nameWithOwner
              pullRequests(first: 100,
                          states:[CLOSED, MERGED]
                          #{cursor ? ", after: \"#{cursor}\"" : ''}) {
                nodes {
                  id
                  url
                  title
                  merged
                  number
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

        octokit_client.post("https://api.github.com/graphql", { query: query }.to_json)
      end

      def pull_requests_from_page_data(response)
        # We're transforming the GraphQL response to the format used to call
        # User::ReputationToken::AwardForPullRequest that is called when the
        # pull request update webhook fires.
        # This allows us to work with pull requests using a single code path.
        response[:data][:repository][:pullRequests][:nodes].map do |pr|
          next if pr[:author].nil? # In rare cases the PR author is null

          {
            action: 'closed',
            author: pr[:author][:login],
            url: "https://api.github.com/repos/#{response[:data][:repository][:nameWithOwner]}/pulls/#{pr[:number]}",
            html_url: pr[:url],
            labels: pr[:labels][:nodes].map { |node| node[:name] },
            state: 'closed',
            pr_id: pr[:id],
            pr_number: pr[:number],
            repo: response[:data][:repository][:nameWithOwner],
            merged: pr[:merged],
            reviews: pr[:reviews][:nodes].map do |node|
              next if node[:author].nil? # In rare cases the review author is null

              {
                node_id: node[:id],
                user: { login: node[:author][:login] }
              }
            end.compact
          }
        end.compact
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

      memoize
      def octokit_client
        Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
      end
    end
  end
end

module Github
  class PullRequest
    class SyncRepo
      include Mandate

      initialize_with :repo

      def call
        pull_requests.each do |pr|
          Github::PullRequest::CreateOrUpdate.(
            pr[:pr_node_id],
            pr_number: pr[:pr_number],
            author_username: pr[:author_username],
            merged_by_username: pr[:merged_by_username],
            repo: pr[:repo],
            reviews: pr[:reviews],
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

          # TODO: filter out PRs we want to ignore (e.g. the v3 bulk rename PRs)
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
              pullRequests(first: 100,
                          states:[CLOSED, MERGED]
                          #{%(, after: "#{cursor}") if cursor}) {
                nodes {
                  id
                  url
                  title
                  number
                  merged
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

        octokit_client.post("https://api.github.com/graphql", { query: query }.to_json).to_h
      end

      def pull_requests_from_page_data(response)
        # We're transforming the GraphQL response to the format used to call
        # User::ReputationToken::AwardForPullRequest that is called when the
        # pull request update webhook fires.
        # This allows us to work with pull requests using a single code path.
        response[:data][:repository][:pullRequests][:nodes].map do |pr|
          {
            action: 'closed',
            author_username: pr[:author_username].present? ? pr[:author_username][:login] : nil,
            url: "https://api.github.com/repos/#{response[:data][:repository][:nameWithOwner]}/pulls/#{pr[:number]}",
            html_url: pr[:url],
            labels: pr[:labels][:nodes].map { |node| node[:name] },
            state: 'closed',
            pr_node_id: pr[:id],
            pr_number: pr[:number],
            repo: response[:data][:repository][:nameWithOwner],
            merged: pr[:merged],
            merged_by_username: pr[:mergedBy].present? ? pr[:mergedBy][:login] : nil,
            reviews: pr[:reviews][:nodes].map do |node|
              {
                node_id: node[:id],
                reviewer_username: node[:author_username].present? ? node[:author_username][:login] : nil
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

      memoize
      def octokit_client
        Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
      end
    end
  end
end

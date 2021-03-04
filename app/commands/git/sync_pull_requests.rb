module Git
  class SyncPullRequests
    include Mandate

    initialize_with :track

    def call
      fetch!
      import!
    end

    private
    attr_reader :pull_requests

    def import!
      pull_requests.each do |pr|
        ::GithubPullRequest.create_or_find_by!(github_id: pr[:pull_request][:id]) do |p|
          p.github_username = pr[:pull_request][:user][:login]
          p.github_event = pr
        end
      end
    end

    def fetch!
      after_cursor = nil
      @pull_requests = []

      loop do
        page_data = fetch_page(after_cursor)
        @pull_requests += pull_requests_from_response(page_data)

        page_info = page_data[:data][:repository][:pullRequests][:pageInfo]
        after_cursor = page_info[:endCursor]
        break unless page_info[:hasNextPage]

        # If the rate limit was exceeded, sleep until it resets
        rate_limit = page_data[:data][:rateLimit]
        next unless rate_limit[:remaining] <= 0

        reset_at = Time.zone.parse(rate_limit[:resetAt])
        seconds_until_reset = reset_at - Time.zone.now
        sleep(seconds_until_reset.ceil)
      end
    end

    def fetch_page(after_cursor)
      after_cursor_argument = after_cursor.nil? ? '' : ", after: \"#{after_cursor}\""

      query = "{
        repository(owner: \"exercism\", name: \"#{track.slug}\") {
          nameWithOwner
          pullRequests(first: 100, states:[CLOSED, MERGED]#{after_cursor_argument}) {
            nodes {
              url
              databaseId
              labels(first: 100) {
                nodes {
                  name
                }
              }
              merged
              number
              author {
                login
              }
              reviews(first: 100) {
                nodes {
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
      }"

      octokit_client.post("https://api.github.com/graphql", { query: query }.to_json)
    end

    def pull_requests_from_response(response)
      # We're transforming the GraphQL response to the format used by the REST API.
      # This allows us to work with pull requests using a single code path.
      response[:data][:repository][:pullRequests][:nodes].map do |pr|
        {
          action: 'closed',
          pull_request: {
            id: pr[:databaseId],
            user: {
              login: pr[:author][:login]
            },
            url: "https://api.github.com/repos/#{response[:data][:repository][:nameWithOwner]}/pulls/#{pr[:number]}",
            html_url: pr[:url],
            labels: pr[:labels][:nodes].map { |node| node[:name] },
            state: 'closed',
            number: pr[:number],
            merged: pr[:merged],
            reviews: pr[:reviews][:nodes].map { |node| { user: { login: node[:author][:login] } } }
          },
          repository: {
            full_name: response[:data][:repository][:nameWithOwner]
          }
        }
      end
    end

    memoize
    def octokit_client
      Octokit::Client.new(access_token: github_access_token)
    end

    def github_access_token
      Exercism.secrets.github_access_token
    end
  end
end

module Git
  class SyncPullRequests
    include Mandate

    initialize_with :track

    def call
      api_pull_requests.each do |api_pr|
        ::GithubPullRequest.create_or_find_by!(github_id: api_pr[:pull_request][:id]) do |pr|
          pr.github_username = api_pr[:pull_request][:user][:login]
          pr.github_event = api_pr
        end
      end
    end

    private
    def api_pull_requests
      api_data[:repository][:pullRequests][:nodes].map do |pr|
        {
          action: 'closed',
          pull_request: {
            id: pr[:databaseId],
            user: {
              login: pr[:author][:login]
            },
            url: "https://api.github.com/repos/#{repository_full_name}/pulls/#{pr[:number]}",
            html_url: pr[:url],
            labels: pr[:labels][:nodes].map { |node| node[:name] },
            state: 'closed',
            number: pr[:number],
            merged: pr[:merged],
            reviews: pr[:reviews][:nodes].map { |node| { user: { login: node[:author][:login] } } }
          },
          repository: {
            full_name: repository_full_name
          }
        }
      end
    end

    def repository_full_name
      api_data[:repository][:nameWithOwner]
    end

    memoize
    def api_data
      query = "{
        repository(owner: \"exercism\", name: \"#{track.slug}\") {
          nameWithOwner
          pullRequests(first: 100, states:[CLOSED, MERGED]) {
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
            }
          }
        }
        rateLimit {
          remaining
          resetAt
        }
      }"

      # TODO: support paging
      results = octokit_client.post("https://api.github.com/graphql", { query: query }.to_json)
      results[:data]
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

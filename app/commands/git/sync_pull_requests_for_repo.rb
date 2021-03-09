module Git
  class SyncPullRequestsForRepo
    include Mandate

    def initialize(repo, created_after: nil)
      @repo = repo
      @created_after = created_after
    end

    def call
      fetch!
      create!
    end

    private
    attr_reader :pull_requests, :repo, :created_after

    def create!
      pull_requests.each do |pr|
        ::Git::PullRequest.new(
          node_id: pr[:pr_id],
          number: pr[:pr_number],
          author_github_username: pr[:author],
          repo: pr[:repo],
          data: pr,
          reviews: pr[:reviews].map do |review|
            ::Git::PullRequestReview.new(
              node_id: review[:node_id],
              reviewer_github_username: review[:user][:login]
            )
          end
        ).save!
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end

    def fetch!
      cursor = nil
      @pull_requests = []

      loop do
        page_data = fetch_page(cursor)

        # TODO: filter out PRs we want to ignore (e.g. the v3 bulk rename PRs)
        @pull_requests += pull_requests_from_page_data(page_data)

        break unless fetch_next_page?(page_data[:data][:repository][:pullRequests])

        cursor = page_data[:data][:repository][:pullRequests][:pageInfo][:endCursor]

        handle_rate_limit(page_data[:data][:rateLimit])
      end
    end

    def fetch_page(cursor)
      # The pull requests are fetched in the order of their creation data,
      # from most recent to oldest
      query = "{
        repository(owner: \"#{repo_owner}\", name: \"#{repo_name}\") {
          nameWithOwner
          pullRequests(first: 100,
                       orderBy: {field: CREATED_AT, direction: DESC},
                       states:[CLOSED, MERGED]
                       #{cursor ? ", after: \"#{cursor}\"" : ''}) {
            nodes {
              id
              url
              title
              merged
              number
              createdAt
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
      }".freeze

      octokit_client.post("https://api.github.com/graphql", { query: query }.to_json)
    end

    def pull_requests_from_page_data(response)
      # We're transforming the GraphQL response to the format used to call
      # User::ReputationToken::AwardForPullRequest that is called when the
      # pull request update webhook fires.
      # This allows us to work with pull requests using a single code path.
      response[:data][:repository][:pullRequests][:nodes].map do |pr|
        next if pr[:author].nil? # In rare cases the PR author is null
        next if too_old?(pr)

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

    def fetch_next_page?(pull_requests_data)
      return false if too_old?(pull_requests_data[:nodes].last)

      pull_requests_data[:pageInfo][:hasNextPage]
    end

    def handle_rate_limit(rate_limit_data)
      # If the rate limit was exceeded, sleep until it resets
      return if rate_limit_data[:remaining].positive?

      reset_at = Time.parse(rate_limit_data[:resetAt]).utc
      seconds_until_reset = reset_at - Time.now.utc
      sleep(seconds_until_reset.ceil)
    end

    def too_old?(pull_request_data)
      return true if pull_request_data.nil?
      return false if created_after.nil?

      Time.parse(pull_request_data[:createdAt]).utc < created_after.utc
    end

    memoize
    def octokit_client
      Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
    end
  end
end

module Git
  class SyncPullRequests
    include Mandate

    def call
      repos.each do |repo|
        SyncPullRequestsForRepo.(repo)
      rescue StandardError => e
        Rails.logger.error "Error syncing pull requests for #{repo}: #{e}"
      end
    end

    private
    def repos
      fetched = []

      loop.with_index do |_, page|
        response = octokit_client.search_repositories("org:exercism is:public", page: page + 1, per_page: 100)
        fetched += response[:items].map { |item| item[:full_name] }

        break fetched if fetched.size >= response[:total_count]
      end
    end

    memoize
    def octokit_client
      Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
    end
  end
end

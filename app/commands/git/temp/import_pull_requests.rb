module Git
  module Temp
    class ImportPullRequests
      include Mandate

      def call
        repos.each do |repo|
          ImportPullRequestsForRepo.(repo)
        rescue StandardError => e
          Rails.logger.error "Error importing pull requests for #{repo}: #{e}"
        end
      end

      private
      def repos
        page = 1
        fetched = []

        loop do
          response = octokit_client.search_repositories("org:exercism is:public", page: page, per_page: 100)
          fetched += response[:items].map { |item| item[:full_name] }
          page += 1

          break fetched if fetched.size >= response[:total_count]
        end
      end

      memoize
      def octokit_client
        Octokit::Client.new(access_token: Exercism.secrets.github_access_token)
      end
    end
  end
end

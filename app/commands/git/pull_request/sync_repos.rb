module Git
  module PullRequest
    class SyncRepos
      include Mandate

      def call
        repos.each do |repo|
          SyncRepo.(repo)
        rescue StandardError => e
          Rails.logger.error "Error syncing pull requests for #{repo}: #{e}"
        end
      end

      private
      def repos
        # The GraphQL API could also have been used. That would have led to more
        # efficient retrieval (less data returned), but we decided against it as
        # the code would be far more verbose
        response = octokit_client.search_repositories("org:exercism is:public")
        response[:items].map { |item| item[:full_name] }
      end

      memoize
      def octokit_client
        Octokit::Client.new(access_token: Exercism.secrets.github_access_token).tap do |c|
          c.auto_paginate = true
        end
      end
    end
  end
end

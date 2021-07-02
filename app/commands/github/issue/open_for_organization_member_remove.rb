# TODO: re-enable class once the organization functionality has been tested properly
# and this functionality is no longer user
module Github
  class Issue
    class OpenForOrganizationMemberRemove
      include Mandate

      initialize_with :organization, :github_username

      def call
        if missing?
          create_issue
        elsif closed?
          reopen_issue
        end
      end

      private
      def create_issue
        title = "🤖 Attempt to remove member `#{github_username}` from org `#{organization}`"
        body = <<~BODY.strip
          The system tried to automatically remove the user `#{github_username}` from the `#{organization}` organization.

          CC @exercism/maintainers-admin
        BODY

        Exercism.octokit_client.create_issue(repo, title, body)
      end

      def reopen_issue
        Exercism.octokit_client.reopen_issue(repo, issue.number)
      end

      def missing?
        issue.nil?
      end

      def closed?
        issue.state == "closed"
      end

      memoize
      def repo
        "exercism/erikschierboom"
      end

      memoize
      def issue
        # TODO: Elevate this into exercism-config gem
        author = "exercism-bot"
        Exercism.octokit_client.search_issues("\"#{github_username}\" \"#{organization}\" is:issue in:title repo:#{repo} author:#{author}")[:items]&.first # rubocop:disable Layout/LineLength
      end
    end
  end
end

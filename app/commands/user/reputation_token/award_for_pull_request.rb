require 'octokit'

class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        award_reputation_to_author
        award_reputation_to_reviewers
      end

      private
      def award_reputation_to_author
        return unless merged?

        user = User.find_by(github_username: github_username)

        # TODO: decide what to do with user that cannot be found
        Rails.logger.error "Missing author: #{github_username}" unless user
        return unless user

        User::ReputationToken::CodeContribution::Create.(user, author_reputation_reason, repo, pr_id, external_link)
      end

      def award_reputation_to_reviewers
        return unless just_closed?

        reviews = octokit_client.pull_request_reviews(repo, pr_id)
        reviewer_usernames = reviews.map { |reviewer| reviewer[:user][:login] }

        reviewers = ::User.where(handle: reviewer_usernames)
        reviewers.find_each do |reviewer|
          User::ReputationToken::CodeReview::Create.(reviewer, repo, pr_id, external_link)
        end

        # TODO: consider what to do with missing reviewers
        missing_reviewers = reviewer_usernames - reviewers.map(&:handle)
        Rails.logger.error "Missing reviewers: #{missing_reviewers.join(', ')}" if missing_reviewers.present?
      end

      def merged?
        params[:merged].present?
      end

      def just_closed?
        action == 'closed'
      end

      def external_link
        params[:html_url]
      end

      def repo
        params[:repo]
      end

      def pr_id
        params[:pr_id]
      end

      def author_reputation_reason
        return :'contributed_code/major' if params[:labels].include?('reputation/contributed_code/major')
        return :'contributed_code/minor' if params[:labels].include?('reputation/contributed_code/minor')

        :'contributed_code/regular'
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
end

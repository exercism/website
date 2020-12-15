require 'octokit'

class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        award_reputation_to_author
      end

      private
      def award_reputation_to_author
        user = User.find_by(github_username: github_username)

        # TODO: decide what to do with user that cannot be found
        Rails.logger.error "Missing author: #{github_username}" unless user
        return unless user

        User::ReputationToken::CodeContribution::Create.(user, external_link, repo, number, reason)
      end

      def external_link
        params[:html_url]
      end

      def repo
        params[:repo]
      end

      def number
        params[:number]
      end

      def reason
        return 'contributed_code/minor' if params[:labels].include?('reputation/contributed_code/minor')
        return 'contributed_code/major' if params[:labels].include?('reputation/contributed_code/major')

        'contributed_code'
      end
    end
  end
end

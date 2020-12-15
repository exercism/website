class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        user = User.find_by(github_username: github_username)

        # TODO: decide what to do with user that cannot be found
        return unless user

        # https://api.github.com/repos/exercism/v3/pulls/2731/reviews

        User::ReputationToken::CodeContribution::Create.(user, external_link, context_key, reason)
      end

      private
      def external_link
        params[:html_url]
      end

      def context_key
        params[:url].remove('https://api.github.com/repos/exercism/')
      end

      def reason
        return 'contributed_code/minor' if params[:labels].include?('reputation/contributed_code/minor')
        return 'contributed_code/major' if params[:labels].include?('reputation/contributed_code/major')

        'contributed_code'
      end
    end
  end
end

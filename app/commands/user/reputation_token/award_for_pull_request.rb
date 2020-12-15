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

        User::ReputationToken::CodeContribution::Create.(user, params[:html_url], size)
      end

      private
      def size
        return :minor if params[:labels].include?('reputation/contributed_code/minor')
        return :major if params[:labels].include?('reputation/contributed_code/major')

        :regular
      end
    end
  end
end

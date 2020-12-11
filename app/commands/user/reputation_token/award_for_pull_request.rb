class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :author, :url, :html_url

      def call
        user = User.find_by(github_username: author)

        # # TODO: decide what to do with user that cannot be found
        # next unless user

        # https://api.github.com/repos/exercism/v3/pulls/2731/reviews

        User::ReputationToken::CodeContribution::Create.(user, html_url)
      end
    end
  end
end

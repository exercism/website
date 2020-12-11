class User
  class ReputationToken
    class AwardForPullRequest
      include Mandate

      initialize_with :action, :author, :url, :html_url

      def call
        # TODO
        # user = User.find_by(github_username: commit.author[:email])

        # # TODO: decide what to do with user that cannot be found
        # next unless user

        # https://api.github.com/repos/exercism/v3/pulls/2731/reviews

        # commit_link = "#{track.repo_url}/commit/#{commit.oid}"
        # User::ReputationToken::CodeContribution::Create.(user, commit_link)
      end
    end
  end
end

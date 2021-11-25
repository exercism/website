class User
  class SetGithubUsername
    include Mandate

    initialize_with :user, :username

    def call
      return if user.github_username == username

      begin
        user.update_column(:github_username, username)
        AwardReputationToUserForPullRequestsJob.perform_later(user)
      rescue ActiveRecord::RecordNotUnique
        # Sometimes users change github usernames which can cause this to violate
      end
    end
  end
end

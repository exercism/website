class User::SetGithubUsername
  include Mandate

  initialize_with :user, :username

  def call
    return if user.github_username == username

    begin
      user.data.with_lock do
        user.data.update!(github_username: username)
      end

      User::ReputationToken::AwardForPullRequestsForUser.defer(user)
    rescue ActiveRecord::RecordNotUnique
      # Sometimes users change github usernames which can cause this to violate
    end
  end
end

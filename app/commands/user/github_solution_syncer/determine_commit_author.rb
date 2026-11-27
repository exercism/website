class User::GithubSolutionSyncer
  # Works out who should be named as the author of the commits synced for a user.
  # Using the user's GitHub noreply address makes GitHub credit the commits to
  # their account without making their real email address public. The bot stays
  # the author if the user has turned off commit_as_user or has no linked GitHub
  # account.
  class DetermineCommitAuthor
    include Mandate

    initialize_with :syncer

    def call
      return bot_author unless syncer.commit_as_user? && github_uid.present? && github_username.present?

      {
        name: user.name.presence || github_username,
        email: "#{github_uid}+#{github_username}@users.noreply.github.com"
      }
    end

    private
    def user = syncer.user
    def github_uid = user.provider == "github" ? user.uid : nil
    def github_username = user.github_username

    def bot_author = { name: User::GithubSolutionSyncer::BOT_NAME, email: User::GithubSolutionSyncer::BOT_EMAIL }
  end
end

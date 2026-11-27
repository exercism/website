class User::GithubSolutionSyncer
  # Works out who should be named as the author of the commits synced for a user.
  # Using the user's GitHub noreply address makes GitHub credit the commits to
  # their account without making their real email address public. If the user has
  # no linked GitHub account, the bot stays the author.
  class DetermineCommitAuthor
    include Mandate

    initialize_with :user

    def call
      return bot_author unless github_uid.present? && github_username.present?

      {
        name: user.name.presence || github_username,
        email: "#{github_uid}+#{github_username}@users.noreply.github.com"
      }
    end

    private
    def github_uid = user.provider == "github" ? user.uid : nil
    def github_username = user.github_username

    def bot_author = { name: User::GithubSolutionSyncer::BOT_NAME, email: User::GithubSolutionSyncer::BOT_EMAIL }
  end
end

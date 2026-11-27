require "test_helper"

class User::GithubSolutionSyncer
  class DetermineCommitAuthorTest < ActiveSupport::TestCase
    test "uses the user's GitHub noreply address when they have a linked account" do
      user = create(:user, name: "Jane Doe", provider: "github", uid: "12345")
      user.data.update!(github_username: "janedoe")

      assert_equal(
        { name: "Jane Doe", email: "12345+janedoe@users.noreply.github.com" },
        DetermineCommitAuthor.(create(:user_github_solution_syncer, user:))
      )
    end

    test "uses the GitHub username when the user has no name" do
      user = create(:user, provider: "github", uid: "12345")
      user.update_column(:name, "")
      user.data.update!(github_username: "janedoe")

      assert_equal "janedoe", DetermineCommitAuthor.(create(:user_github_solution_syncer, user:))[:name]
    end

    test "falls back to the bot without a linked GitHub account" do
      user = create(:user)

      assert_equal(
        { name: User::GithubSolutionSyncer::BOT_NAME, email: User::GithubSolutionSyncer::BOT_EMAIL },
        DetermineCommitAuthor.(create(:user_github_solution_syncer, user:))
      )
    end

    test "falls back to the bot when the GitHub username is missing" do
      user = create(:user, provider: "github", uid: "12345")

      assert_equal User::GithubSolutionSyncer::BOT_EMAIL, DetermineCommitAuthor.(create(:user_github_solution_syncer, user:))[:email]
    end

    test "falls back to the bot when the account is linked through another provider" do
      user = create(:user, provider: "discord", uid: "12345")
      user.data.update!(github_username: "janedoe")

      assert_equal User::GithubSolutionSyncer::BOT_EMAIL, DetermineCommitAuthor.(create(:user_github_solution_syncer, user:))[:email]
    end

    test "uses the bot when the user has turned off commit_as_user" do
      user = create(:user, name: "Jane Doe", provider: "github", uid: "12345")
      user.data.update!(github_username: "janedoe")
      syncer = create(:user_github_solution_syncer, user:, commit_as_user: false)

      assert_equal(
        { name: User::GithubSolutionSyncer::BOT_NAME, email: User::GithubSolutionSyncer::BOT_EMAIL },
        DetermineCommitAuthor.(syncer)
      )
    end
  end
end

require "test_helper"

class User::GithubSolutionSyncer
  class DetermineCommitAuthorTest < ActiveSupport::TestCase
    test "uses the user's GitHub noreply address when they have a linked account" do
      user = create(:user, name: "Jane Doe", provider: "github", uid: "12345")
      user.data.update!(github_username: "janedoe")

      assert_equal(
        { name: "Jane Doe", email: "12345+janedoe@users.noreply.github.com" },
        DetermineCommitAuthor.(user)
      )
    end

    test "uses the GitHub username when the user has no name" do
      user = create(:user, provider: "github", uid: "12345")
      user.update_column(:name, "")
      user.data.update!(github_username: "janedoe")

      assert_equal "janedoe", DetermineCommitAuthor.(user)[:name]
    end

    test "falls back to the bot without a linked GitHub account" do
      user = create(:user)

      assert_equal(
        { name: User::GithubSolutionSyncer::BOT_NAME, email: User::GithubSolutionSyncer::BOT_EMAIL },
        DetermineCommitAuthor.(user)
      )
    end

    test "falls back to the bot when the GitHub username is missing" do
      user = create(:user, provider: "github", uid: "12345")

      assert_equal User::GithubSolutionSyncer::BOT_EMAIL, DetermineCommitAuthor.(user)[:email]
    end

    test "falls back to the bot when the account is linked through another provider" do
      user = create(:user, provider: "discord", uid: "12345")
      user.data.update!(github_username: "janedoe")

      assert_equal User::GithubSolutionSyncer::BOT_EMAIL, DetermineCommitAuthor.(user)[:email]
    end
  end
end

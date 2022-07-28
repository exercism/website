require "test_helper"

class User::SetGithubUsernameTest < ActiveSupport::TestCase
  test "sets username" do
    username = "user22"
    user = create :user
    User::SetGithubUsername.(user, username)
    assert_equal username, user.github_username
  end

  test "copes with duplicate gh username but unauthed" do
    username = "user22"
    user = create :user
    create :user, github_username: username

    User::SetGithubUsername.(user, username)
    assert_nil user.reload.github_username
  end

  test "recalculate pull request reputation for uid matches that change the github_username" do
    user = create :user
    assert_enqueued_with(job: MandateJob, args: [User::ReputationToken::AwardForPullRequestsForUser.name, user],
      queue: 'reputation') do
      User::SetGithubUsername.(user, "user22")
    end
  end
end

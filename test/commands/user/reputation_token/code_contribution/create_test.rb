require "test_helper"

class User::ReputationToken::CodeContribution::CreateTest < ActiveSupport::TestCase
  test "creates code contribution reputation token" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_id = 1347
    reason = 'contributed_code/regular'
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::CodeContribution::Create.(user, external_link, repo, pr_id, reason)

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_link
    assert_equal 'contributed_code/exercism/v3/pulls/1347', rt.context_key
    assert_equal 'contributed_code/regular', rt.reason
    assert_equal :building, rt.category
    assert_equal 10, rt.value
  end

  test "updates amount when reason changes contribution reputation token" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_id = 1347
    reason = 'contributed_code/minor'
    user = create :user, handle: "User22", github_username: "user22"
    create :user_reputation_token, user: user, reason: 'contributed_code/regular', context_key: 'contributed_code/exercism/v3/pulls/1347', category: :building # rubocop:disable Layout/LineLength

    User::ReputationToken::CodeContribution::Create.(user, external_link, repo, pr_id, reason)

    assert_equal 5, user.reputation_tokens.first.value
  end

  test "idempotent" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_id = 1347
    reason = 'contributed_code/regular'
    user = create :user, handle: "User22", github_username: "user22"

    assert_idempotent_command do
      User::ReputationToken::CodeContribution::Create.(user, external_link, repo, pr_id, reason)
    end
  end
end

require "test_helper"

class User::ReputationToken::CodeReview::CreateTest < ActiveSupport::TestCase
  test "creates code review reputation token" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_id = 1347
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::CodeReview::Create.(user, external_link, repo, pr_id)

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_link
    assert_equal 'reviewed_code/exercism/v3/pulls/1347', rt.context_key
    assert_equal 'reviewed_code', rt.reason
    assert_equal :building, rt.category
    assert_equal 3, rt.value
  end

  test "idempotent" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_id = 1347
    user = create :user, handle: "User22", github_username: "user22"

    assert_idempotent_command do
      User::ReputationToken::CodeReview::Create.(user, external_link, repo, pr_id)
    end
  end
end

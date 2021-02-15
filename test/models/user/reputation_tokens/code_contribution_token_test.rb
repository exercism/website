require "test_helper"

class User::ReputationTokens::CodeContributionTokenTest < ActiveSupport::TestCase
  test "creates code contribution reputation token" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_id = 1347
    level = :major
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo: repo,
      level: level,
      pr_id: pr_id,
      external_link: external_link
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeContributionToken, rt.class
    assert_equal "You contributed code via <strong>PR##{pr_id}</strong> on <strong>#{repo}</strong>", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_link
    assert_equal "#{user.id}|code_contribution|PR#exercism/v3/1347", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :contributed_code, rt.reason
    assert_equal level, rt.level
    assert_equal 15, rt.value
  end
end

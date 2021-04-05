require "test_helper"

class User::ReputationTokens::CodeContributionTokenTest < ActiveSupport::TestCase
  test "creates code contribution reputation token for major level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/ruby'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    level = :major
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo: repo,
      level: level,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeContributionToken, rt.class
    assert_equal "You created <strong>PR##{pr_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_contribution|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :contributed_code, rt.reason
    assert_equal level, rt.level
    assert_equal 30, rt.value
  end

  test "creates code contribution reputation token for regular level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/ruby'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    level = :regular
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo: repo,
      level: level,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeContributionToken, rt.class
    assert_equal "You created <strong>PR##{pr_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_contribution|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :contributed_code, rt.reason
    assert_equal level, rt.level
    assert_equal 12, rt.value
  end

  test "creates code contribution reputation token for minor level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/ruby'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    level = :minor
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo: repo,
      level: level,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeContributionToken, rt.class
    assert_equal "You created <strong>PR##{pr_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_contribution|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :contributed_code, rt.reason
    assert_equal level, rt.level
    assert_equal 5, rt.value
  end

  test "linked to track if repo is a track repo" do
    user = create :user, handle: "User22", github_username: "user22"
    track = create :track, repo_url: 'https://github.com/exercism/ruby'

    token = User::ReputationToken::Create.(
      user,
      :code_contribution,
      level: :regular,
      repo: 'exercism/ruby',
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: "The cat sat on the mat",
      external_url: 'https://api.github.com/repos/exercism/ruby/pulls/1347'
    )

    assert_equal track, token.track
  end

  test "not linked to track if repo is not a track repo" do
    user = create :user, handle: "User22", github_username: "user22"

    token = User::ReputationToken::Create.(
      user,
      :code_contribution,
      level: :regular,
      repo: 'exercism/v3',
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: "The cat sat on the mat",
      external_url: 'https://api.github.com/repos/exercism/v3/pulls/1347'
    )

    assert_nil token.track
  end
end

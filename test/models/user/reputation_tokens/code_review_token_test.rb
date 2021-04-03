require "test_helper"

class User::ReputationTokens::CodeReviewTokenTest < ActiveSupport::TestCase
  test "creates code review reputation token for minor level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :minor,
      repo: repo,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeReviewToken, rt.class
    assert_equal "You reviewed <strong>PR##{pr_number}</strong> on <strong>v3</strong>: #{pr_title}", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_review|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :reviewed_code, rt.reason
    assert_equal :minor, rt.level
    assert_equal 2, rt.value
  end

  test "creates code review reputation token for regular level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :regular,
      repo: repo,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeReviewToken, rt.class
    assert_equal "You reviewed <strong>PR##{pr_number}</strong> on <strong>v3</strong>: #{pr_title}", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_review|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :reviewed_code, rt.reason
    assert_equal :regular, rt.level
    assert_equal 5, rt.value
  end

  test "creates code review reputation token for major level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :major,
      repo: repo,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeReviewToken, rt.class
    assert_equal "You reviewed <strong>PR##{pr_number}</strong> on <strong>v3</strong>: #{pr_title}", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_review|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :reviewed_code, rt.reason
    assert_equal :major, rt.level
    assert_equal 10, rt.value
  end

  test "linked to track if repo is a track repo" do
    user = create :user, handle: "User22", github_username: "user22"
    track = create :track, repo_url: 'https://github.com/exercism/ruby'

    token = User::ReputationToken::Create.(
      user,
      :code_review,
      level: :minor,
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
      :code_review,
      level: :minor,
      repo: 'exercism/v3',
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: "The cat sat on the mat",
      external_url: 'https://api.github.com/repos/exercism/v3/pulls/1347'
    )

    assert_nil token.track
  end
end

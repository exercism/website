require "test_helper"

class User::ReputationTokens::CodeMergeTokenTest < ActiveSupport::TestCase
  test "creates code merge reputation token" do
    external_link = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/haskell'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_merge,
      repo: repo,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_link: external_link
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeMergeToken, rt.class
    assert_equal "You merged <strong>PR##{pr_number}</strong> on <strong>haskell</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_link
    assert_equal "#{user.id}|code_merge|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :merged_code, rt.reason
    assert_equal 2, rt.value
  end

  test "linked to track if repo is a track repo" do
    user = create :user, handle: "User22", github_username: "user22"
    track = create :track, repo_url: 'https://github.com/exercism/ruby'

    token = User::ReputationToken::Create.(
      user,
      :code_merge,
      repo: 'exercism/ruby',
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: "The cat sat on the mat",
      external_link: 'https://api.github.com/repos/exercism/ruby/pulls/1347'
    )

    assert_equal track, token.track
  end

  test "not linked to track if repo is not a track repo" do
    user = create :user, handle: "User22", github_username: "user22"

    token = User::ReputationToken::Create.(
      user,
      :code_merge,
      repo: 'exercism/v3',
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: "The cat sat on the mat",
      external_link: 'https://api.github.com/repos/exercism/v3/pulls/1347'
    )

    assert_nil token.track
  end
end

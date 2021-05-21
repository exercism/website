require "test_helper"

class User::ReputationTokens::CodeMergeTokenTest < ActiveSupport::TestCase
  test "creates code merge reputation token with janitorial level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/haskell'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_merge,
      level: :janitorial,
      repo: repo,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeMergeToken, rt.class
    assert_equal "You merged <strong>PR##{pr_number}</strong> on <strong>haskell</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_merge|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :maintaining, rt.category
    assert_equal :merged_code, rt.reason
    assert_equal :janitorial, rt.level
    assert_equal 1, rt.value
  end

  test "creates code merge reputation token with reviewal level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/haskell'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_merge,
      level: :reviewal,
      repo: repo,
      pr_node_id: pr_node_id,
      pr_number: pr_number,
      pr_title: pr_title,
      external_url: external_url
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::CodeMergeToken, rt.class
    assert_equal "You merged <strong>PR##{pr_number}</strong> on <strong>haskell</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_merge|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :maintaining, rt.category
    assert_equal :merged_code, rt.reason
    assert_equal :reviewal, rt.level
    assert_equal 5, rt.value
  end

  repos = [
    ['exercism/ruby', 'track'],
    ['exercism/ruby-test-runner', 'test runner'],
    ['exercism/ruby-analyzer', 'analyzer'],
    ['exercism/ruby-representer', 'representer']
  ]
  repos.each do |repo, description|
    test "linked to track if repo is a #{description} repo" do
      user = create :user, handle: "User22", github_username: "user22"
      track = create :track, repo_url: 'https://github.com/exercism/ruby'

      token = User::ReputationToken::Create.(
        user,
        :code_merge,
        level: :reviewal,
        repo: repo,
        pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        pr_number: 1347,
        pr_title: "The cat sat on the mat",
        external_url: 'https://api.github.com/repos/exercism/ruby/pulls/1347'
      )

      assert_equal track, token.track
    end
  end

  test "not linked to track if repo is not a track repo" do
    user = create :user, handle: "User22", github_username: "user22"

    token = User::ReputationToken::Create.(
      user,
      :code_merge,
      level: :reviewal,
      repo: 'exercism/v3',
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: "The cat sat on the mat",
      external_url: 'https://api.github.com/repos/exercism/v3/pulls/1347'
    )

    assert_nil token.track
  end
end

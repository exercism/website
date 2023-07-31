require "test_helper"

class User::ReputationTokens::CodeContributionTokenTest < ActiveSupport::TestCase
  test "creates code contribution reputation token for major level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/ruby'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    level = :large
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo:,
      level:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      merged_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeContributionToken, rt
    assert_equal "You created <strong>PR##{pr_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_contribution|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :contributed_code, rt.reason
    assert_equal level, rt.level
    assert_equal 30, rt.value
    assert_equal merged_at.to_date, rt.earned_on
  end

  test "creates code contribution reputation token for regular level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/ruby'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    level = :medium
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo:,
      level:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      merged_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeContributionToken, rt
    assert_equal "You created <strong>PR##{pr_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_contribution|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :contributed_code, rt.reason
    assert_equal level, rt.level
    assert_equal 12, rt.value
    assert_equal merged_at.to_date, rt.earned_on
  end

  test "creates code contribution reputation token for minor level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/ruby'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    level = :small
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_contribution,
      repo:,
      level:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      merged_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeContributionToken, rt
    assert_equal "You created <strong>PR##{pr_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_contribution|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :building, rt.category
    assert_equal :contributed_code, rt.reason
    assert_equal level, rt.level
    assert_equal 5, rt.value
    assert_equal merged_at.to_date, rt.earned_on
  end

  test "uses current time for earned date when closed_at and merged_at are nil" do
    freeze_time do
      external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
      repo = 'exercism/ruby'
      pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      pr_number = 1347
      pr_title = "The cat sat on the mat"
      level = :large
      user = create :user, handle: "User22", github_username: "user22"

      User::ReputationToken::Create.(
        user,
        :code_contribution,
        repo:,
        level:,
        pr_node_id:,
        pr_number:,
        pr_title:,
        merged_at: nil,
        external_url:
      )

      assert_equal 1, user.reputation_tokens.size
      rt = user.reputation_tokens.first

      assert_instance_of User::ReputationTokens::CodeContributionToken, rt
      assert_equal "You created <strong>PR##{pr_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
      assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
      assert_equal "#{user.id}|code_contribution|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
      assert_equal :building, rt.category
      assert_equal :contributed_code, rt.reason
      assert_equal level, rt.level
      assert_equal 30, rt.value
      assert_equal Time.current.to_date, rt.earned_on
    end
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
        :code_contribution,
        level: :medium,
        repo:,
        pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        pr_number: 1347,
        pr_title: "The cat sat on the mat",
        merged_at: Time.parse('2020-04-03T14:54:57Z').utc,
        external_url: 'https://api.github.com/repos/exercism/ruby/pulls/1347'
      )

      assert_equal track, token.track
    end
  end

  test "not linked to track if repo is not a track repo" do
    user = create :user, handle: "User22", github_username: "user22"

    token = User::ReputationToken::Create.(
      user,
      :code_contribution,
      level: :medium,
      repo: 'exercism/v3',
      pr_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 1347,
      pr_title: "The cat sat on the mat",
      merged_at: Time.parse('2020-04-03T14:54:57Z').utc,
      external_url: 'https://api.github.com/repos/exercism/v3/pulls/1347'
    )

    assert_nil token.track
  end
end

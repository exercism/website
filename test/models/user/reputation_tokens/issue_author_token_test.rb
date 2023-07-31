require "test_helper"

class User::ReputationTokens::IssueAuthorTokenTest < ActiveSupport::TestCase
  test "creates issue author reputation token for large level" do
    external_url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    repo = 'exercism/ruby'
    issue_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    issue_number = 1347
    issue_title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    level = :large
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :issue_author,
      repo:,
      level:,
      issue_node_id:,
      issue_number:,
      issue_title:,
      opened_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::IssueAuthorToken, rt
    assert_equal "You opened <strong>issue##{issue_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/issues/1347', rt.external_url
    assert_equal "#{user.id}|issue_author|issue#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :maintaining, rt.category
    assert_equal :opened_issue, rt.reason
    assert_equal level, rt.level
    assert_equal 30, rt.value
    assert_equal opened_at.to_date, rt.earned_on
  end

  test "creates issue author reputation token for massive level" do
    external_url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    repo = 'exercism/ruby'
    issue_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    issue_number = 1347
    issue_title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    level = :massive
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :issue_author,
      repo:,
      level:,
      issue_node_id:,
      issue_number:,
      issue_title:,
      opened_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::IssueAuthorToken, rt
    assert_equal "You opened <strong>issue##{issue_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/issues/1347', rt.external_url
    assert_equal "#{user.id}|issue_author|issue#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :maintaining, rt.category
    assert_equal :opened_issue, rt.reason
    assert_equal level, rt.level
    assert_equal 100, rt.value
    assert_equal opened_at.to_date, rt.earned_on
  end

  test "uses current time for earned date when opened_at is nil" do
    freeze_time do
      external_url = 'https://api.github.com/repos/exercism/v3/issues/1347'
      repo = 'exercism/ruby'
      issue_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      issue_number = 1347
      issue_title = "The cat sat on the mat"
      level = :large
      user = create :user, handle: "User22", github_username: "user22"

      User::ReputationToken::Create.(
        user,
        :issue_author,
        repo:,
        level:,
        issue_node_id:,
        issue_number:,
        issue_title:,
        opened_at: nil,
        external_url:
      )

      assert_equal 1, user.reputation_tokens.size
      rt = user.reputation_tokens.first

      assert_instance_of User::ReputationTokens::IssueAuthorToken, rt
      assert_equal "You opened <strong>issue##{issue_number}</strong> on <strong>ruby</strong>: The cat sat on the mat", rt.text
      assert_equal 'https://api.github.com/repos/exercism/v3/issues/1347', rt.external_url
      assert_equal "#{user.id}|issue_author|issue#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
      assert_equal :maintaining, rt.category
      assert_equal :opened_issue, rt.reason
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
        :issue_author,
        level: :large,
        repo:,
        issue_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        issue_number: 1347,
        issue_title: "The cat sat on the mat",
        opened_at: Time.parse('2020-04-03T14:54:57Z').utc,
        external_url: 'https://api.github.com/repos/exercism/ruby/issues/1347'
      )

      assert_equal track, token.track
    end
  end

  test "not linked to track if repo is not a track repo" do
    user = create :user, handle: "User22", github_username: "user22"

    token = User::ReputationToken::Create.(
      user,
      :issue_author,
      level: :large,
      repo: 'exercism/v3',
      issue_node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      issue_number: 1347,
      issue_title: "The cat sat on the mat",
      opened_at: Time.parse('2020-04-03T14:54:57Z').utc,
      external_url: 'https://api.github.com/repos/exercism/v3/issues/1347'
    )

    assert_nil token.track
  end
end

require "test_helper"

class User::ReputationToken::AwardForIssueTest < ActiveSupport::TestCase
  %w[labeled unlabeled].each do |action|
    test "adds reputation token to issue author when action is #{action}" do
      opened_by_username = 'user22'
      repo = 'exercism/v3'
      node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      number = 1347
      title = "The cat sat on the mat"
      opened_at = Time.parse('2020-04-03T14:54:57Z').utc
      url = 'https://api.github.com/repos/exercism/v3/issues/1347'
      html_url = 'https://github.com/exercism/v3/issue/1347'
      labels = ['x:rep/large']
      user = create :user, handle: "User-22", github_username: "user22"

      User::ReputationToken::AwardForIssue.(
        action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
      )

      assert_equal 1, User::ReputationTokens::IssueAuthorToken.where(user:).count
      token = User::ReputationTokens::IssueAuthorToken.where(user:).first
      assert opened_at.to_date, token.earned_on
    end
  end

  %w[opened edited deleted closed reopened transferred].each do |action|
    test "no reputation is awarded when action is #{action}" do
      opened_by_username = 'user22'
      repo = 'exercism/v3'
      node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      number = 1347
      title = "The cat sat on the mat"
      opened_at = Time.parse('2020-04-03T14:54:57Z').utc
      url = 'https://api.github.com/repos/exercism/v3/issues/1347'
      html_url = 'https://github.com/exercism/v3/issue/1347'
      labels = ['x:rep/large']
      user = create :user, handle: "User-22", github_username: "user22"

      User::ReputationToken::AwardForIssue.(
        action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
      )

      refute User::ReputationTokens::IssueAuthorToken.where(user:).exists?
    end
  end

  ['x:size/tiny', 'x:size/small', 'x:size/medium', 'x:size/large', 'x:size/massive'].each do |label|
    test "no reputation is awarded when size label is #{label}" do
      action = 'labeled'
      opened_by_username = 'user22'
      repo = 'exercism/v3'
      node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      number = 1347
      title = "The cat sat on the mat"
      opened_at = Time.parse('2020-04-03T14:54:57Z').utc
      url = 'https://api.github.com/repos/exercism/v3/issues/1347'
      html_url = 'https://github.com/exercism/v3/issue/1347'
      labels = [label]
      user = create :user, handle: "User-22", github_username: "user22"

      User::ReputationToken::AwardForIssue.(
        action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
      )

      refute User::ReputationTokens::IssueAuthorToken.where(user:).exists?
    end
  end

  ['x:rep/tiny', 'x:rep/small', 'x:rep/medium'].each do |label|
    test "no reputation is awarded when rep label is #{label}" do
      action = 'labeled'
      opened_by_username = 'user22'
      repo = 'exercism/v3'
      node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      number = 1347
      title = "The cat sat on the mat"
      opened_at = Time.parse('2020-04-03T14:54:57Z').utc
      url = 'https://api.github.com/repos/exercism/v3/issues/1347'
      html_url = 'https://github.com/exercism/v3/issue/1347'
      labels = [label]
      user = create :user, handle: "User-22", github_username: "user22", roles: [:admin]

      User::ReputationToken::AwardForIssue.(
        action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
      )

      refute User::ReputationTokens::IssueAuthorToken.where(user:).exists?
    end
  end

  test "no reputation is awarded when author could not be found" do
    action = 'labeled'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = ['x:rep/large']

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    refute User::ReputationTokens::IssueAuthorToken.exists?
  end

  test "no reputation is awarded when there is no rep label" do
    action = 'labeled'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = ['bug']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    refute User::ReputationTokens::IssueAuthorToken.where(user:).exists?
  end

  test "reputation is awarded once per author per issue" do
    action = 'closed'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    create :user_issue_author_reputation_token, user:, level: :large,
      params: {
        repo:,
        pr_node_id: node_id,
        opened_at:
      }

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    assert_equal 1, User::ReputationTokens::IssueAuthorToken.where(user:).size
  end

  %w[ruby ruby-test-runner ruby-analyzer ruby-representer].each do |repo_name|
    test "reputation token with repo is #{repo_name} is linked to correct track" do
      action = 'labeled'
      opened_by_username = 'user22'
      repo = "exercism/#{repo_name}"
      node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      number = 1347
      title = "The cat sat on the mat"
      opened_at = Time.parse('2020-04-03T14:54:57Z').utc
      url = "https://api.github.com/repos/exercism/#{repo_name}/issues/1347"
      html_url = "https://github.com/exercism/#{repo_name}/issue/1347"
      labels = ['x:rep/massive']
      user = create :user, handle: "User-22", github_username: "user22"
      track = create :track, repo_url: 'https://github.com/exercism/ruby'

      User::ReputationToken::AwardForIssue.(
        action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
      )

      token = User::ReputationTokens::IssueAuthorToken.where(user:).first
      assert_equal track, token.track
    end
  end

  test "reputation not awarded to issue author if author is not known" do
    action = 'closed'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = []

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    refute User::ReputationTokens::IssueAuthorToken.exists?
  end

  test "issue with large and massive rep adds reputation token for greatest rep" do
    action = 'labeled'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = ['x:rep/large', 'x:rep/massive']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    assert_equal 100, user.reputation_tokens.last.value
  end

  test "issue ignores irrelevant labels" do
    action = 'labeled'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = ['duplicate', 'x:rep/large', 'bug']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    assert_equal 30, user.reputation_tokens.last.value
  end

  test "reputation value changed if size label changes" do
    action = 'labeled'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = ['x:rep/large']
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_issue_author_reputation_token, user:, level: :massive,
      external_url: html_url,
      params: {
        repo:,
        issue_node_id: node_id,
        opened_at:
      }

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    user.reload
    assert_equal 1, user.reputation_tokens.size
    assert_equal 30, reputation_token.reload.value
    assert_equal 30, user.reputation
  end

  ['x:rep/tiny', 'x:rep/small', 'x:rep/medium'].each do |label|
    test "reputation token removed if rep label changes to #{label}" do
      action = 'labeled'
      opened_by_username = 'user22'
      repo = 'exercism/v3'
      node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      number = 1347
      title = "The cat sat on the mat"
      opened_at = Time.parse('2020-04-03T14:54:57Z').utc
      url = 'https://api.github.com/repos/exercism/v3/issues/1347'
      html_url = 'https://github.com/exercism/v3/issue/1347'
      labels = [label]
      user = create :user, handle: "User-22", github_username: "user22"
      create :user_issue_author_reputation_token, user:, level: :massive,
        external_url: html_url,
        params: {
          repo:,
          issue_node_id: node_id,
          opened_at:
        }

      # Sanity check
      assert_equal 100, user.reload.reputation

      User::ReputationToken::AwardForIssue.(
        action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
      )

      assert_empty user.reload.reputation_tokens
      assert_equal 0, user.reload.reputation
    end
  end

  test "reputation token removed if rep label is removed" do
    action = 'unlabeled'
    opened_by_username = 'user22'
    repo = 'exercism/v3'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    number = 1347
    title = "The cat sat on the mat"
    opened_at = Time.parse('2020-04-03T14:54:57Z').utc
    url = 'https://api.github.com/repos/exercism/v3/issues/1347'
    html_url = 'https://github.com/exercism/v3/issue/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    create :user_issue_author_reputation_token, user:, level: :massive,
      external_url: html_url,
      params: {
        repo:,
        issue_node_id: node_id,
        opened_at:
      }

    # Sanity check
    assert_equal 100, user.reload.reputation

    User::ReputationToken::AwardForIssue.(
      action:, opened_by_username:, url:, html_url:, labels:, repo:, node_id:, number:, title:, opened_at:
    )

    assert_empty user.reload.reputation_tokens
    assert_equal 0, user.reload.reputation
  end
end

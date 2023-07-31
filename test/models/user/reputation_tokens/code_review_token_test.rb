require "test_helper"

class User::ReputationTokens::CodeReviewTokenTest < ActiveSupport::TestCase
  test "creates code review reputation token for minor level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :small,
      repo:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      merged_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeReviewToken, rt
    assert_equal "You reviewed <strong>PR##{pr_number}</strong> on <strong>v3</strong>: #{pr_title}", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_review|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :maintaining, rt.category
    assert_equal :reviewed_code, rt.reason
    assert_equal :small, rt.level
    assert_equal 2, rt.value
    assert_equal merged_at.to_date, rt.earned_on
  end

  test "creates code review reputation token for regular level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :medium,
      repo:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      merged_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeReviewToken, rt
    assert_equal "You reviewed <strong>PR##{pr_number}</strong> on <strong>v3</strong>: #{pr_title}", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_review|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :maintaining, rt.category
    assert_equal :reviewed_code, rt.reason
    assert_equal :medium, rt.level
    assert_equal 5, rt.value
    assert_equal merged_at.to_date, rt.earned_on
  end

  test "creates code review reputation token for major level" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :large,
      repo:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      merged_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeReviewToken, rt
    assert_equal "You reviewed <strong>PR##{pr_number}</strong> on <strong>v3</strong>: #{pr_title}", rt.text
    assert_equal 'https://api.github.com/repos/exercism/v3/pulls/1347', rt.external_url
    assert_equal "#{user.id}|code_review|PR#MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ", rt.uniqueness_key
    assert_equal :maintaining, rt.category
    assert_equal :reviewed_code, rt.reason
    assert_equal :large, rt.level
    assert_equal 10, rt.value
    assert_equal merged_at.to_date, rt.earned_on
  end

  test "uses merged_at for earned date when pr was merged" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    merged_at = Time.parse('2020-04-03T14:54:57Z').utc
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :small,
      repo:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      merged_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeReviewToken, rt
    assert_equal merged_at.to_date, rt.earned_on
  end

  test "uses closed_at for earned date when pr was closed" do
    external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    repo = 'exercism/v3'
    pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    pr_number = 1347
    pr_title = "The cat sat on the mat"
    closed_at = Time.parse('2020-04-03T14:54:57Z').utc
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :code_review,
      level: :small,
      repo:,
      pr_node_id:,
      pr_number:,
      pr_title:,
      closed_at:,
      external_url:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::CodeReviewToken, rt
    assert_equal closed_at.to_date, rt.earned_on
  end

  test "uses current time for earned date when closed_at and merged_at are nil" do
    freeze_time do
      external_url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
      repo = 'exercism/v3'
      pr_node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
      pr_number = 1347
      pr_title = "The cat sat on the mat"
      user = create :user, handle: "User22", github_username: "user22"

      User::ReputationToken::Create.(
        user,
        :code_review,
        level: :small,
        repo:,
        pr_node_id:,
        pr_number:,
        pr_title:,
        closed_at: nil,
        merged_at: nil,
        external_url:
      )

      assert_equal 1, user.reputation_tokens.size
      rt = user.reputation_tokens.first

      assert_instance_of User::ReputationTokens::CodeReviewToken, rt
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
        :code_review,
        level: :small,
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
      :code_review,
      level: :small,
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

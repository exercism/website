require "test_helper"

class ProcessPullRequestUpdateJobTest < ActiveJob::TestCase
  test "reputation tokens are awarded for pull request" do
    action = 'closed'
    author = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    repo = 'exercism/fsharp'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    title = "The cat sat on the mat"
    created_at = Time.parse("2019-05-15T15:20:33Z").utc
    number = 1347
    merged = false
    merged_at = nil
    merged_by = nil
    state = 'open'
    reviews = [
      { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', reviewer_username: "reviewer71",
        submitted_at: Time.parse("2019-05-23T12:12:13Z").utc },
      { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI5', reviewer_username: "reviewer13",
        submitted_at: Time.parse("2019-05-24T10:56:29Z").utc }
    ]

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
      to_return(status: 200, body: [
        { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', user: { login: "reviewer71" },
          submitted_at: "2019-05-23T12:12:13Z" },
        { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI5', user: { login: "reviewer13" },
          submitted_at: "2019-05-24T10:56:29Z" }
      ].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.expects(:call).with(
      action:,
      author_username: author,
      url:,
      html_url:,
      labels:,
      repo:,
      node_id:,
      title:,
      created_at:,
      number:,
      merged:,
      merged_at:,
      merged_by_username: merged_by,
      state:,
      reviews:
    )

    ProcessPullRequestUpdateJob.perform_now(
      action:,
      author_username: author,
      url:,
      html_url:,
      labels:,
      repo:,
      node_id:,
      title:,
      created_at:,
      number:,
      merged:,
      merged_at:,
      merged_by_username: merged_by,
      state:
    )
  end

  test "creates pull request record" do
    action = 'closed'
    author = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    repo = 'exercism/fsharp'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    title = "The cat sat on the mat"
    created_at = Time.parse("2019-05-15T15:20:33Z").utc
    number = 1347
    merged = true
    merged_at = Time.parse("2019-05-15T16:43:00Z").utc
    merged_by = 'merger11'
    state = 'open'
    reviews = [
      { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', reviewer_username: "reviewer71",
        submitted_at: Time.parse("2019-05-23T12:12:13Z").utc },
      { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI5', reviewer_username: "reviewer13",
        submitted_at: Time.parse("2019-05-24T10:56:29Z").utc }
    ]

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
      to_return(status: 200, body: [
        { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', user: { login: "reviewer71" },
          submitted_at: "2019-05-23T12:12:13Z" },
        { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI5', user: { login: "reviewer13" },
          submitted_at: "2019-05-24T10:56:29Z" }
      ].to_json, headers: { 'Content-Type' => 'application/json' })

    ProcessPullRequestUpdateJob.perform_now(
      action:,
      author_username: author,
      url:,
      html_url:,
      labels:,
      repo:,
      node_id:,
      title:,
      created_at:,
      number:,
      state:,
      merged:,
      merged_at:,
      merged_by_username: merged_by
    )

    pr = Github::PullRequest.find_by(node_id:)
    expected_data = {
      url:,
      repo:,
      state:,
      title:,
      action:,
      labels:,
      merged:,
      number:,
      node_id:,
      reviews:,
      html_url:,
      merged_at:,
      created_at:,
      author_username: author,
      merged_by_username: merged_by
    }
    assert_equal node_id, pr.node_id
    assert_equal number, pr.number
    assert_equal title, pr.title
    assert_equal repo, pr.repo
    assert_equal author, pr.author_username
    assert_equal merged_by, pr.merged_by_username
    assert_equal expected_data, pr.data
  end

  test "retrieves all reviews" do
    action = 'closed'
    author = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    repo = 'exercism/fsharp'
    node_id = 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ'
    title = "The cat sat on the mat"
    created_at = Time.parse("2019-05-15T15:20:33Z").utc
    number = 1347
    merged = false
    merged_at = nil
    merged_by = nil
    state = 'open'

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
      to_return(
        status: 200,
        body: [
          { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', user: { login: "reviewer71" } },
          { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI5', user: { login: "reviewer13" } }
        ].to_json,
        headers: {
          'Link': "<https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?page=2&per_page=100>; rel=\"next\", <https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?page=2&per_page=100>; rel=\"last\"", # rubocop:disable Layout/LineLength
          'Content-Type': 'application/json'
        }
      )

    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?page=2&per_page=100").
      to_return(
        status: 200,
        body: [
          { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI6', user: { login: "reviewer71" } }
        ].to_json,
        headers: {
          'Link': "<https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?page=2&per_page=100>; rel=\"last\"", # rubocop:disable Layout/LineLength
          'Content-Type': 'application/json'
        }
      )

    ProcessPullRequestUpdateJob.perform_now(
      action:,
      author_username: author,
      url:,
      html_url:,
      labels:,
      repo:,
      node_id:,
      title:,
      created_at:,
      number:,
      state:,
      merged:,
      merged_at:,
      merged_by_username: merged_by
    )

    assert_equal 3, Github::PullRequestReview.find_each.size
  end
end

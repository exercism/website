require "test_helper"

class ProcessPullRequestUpdateJobTest < ActiveJob::TestCase
  %w[closed labeled unlabeled].each do |action|
    test "reputation tokens are awarded when action is #{action}" do
      pull_request_update = {
        action:,
        author_username: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        repo: 'exercism/fsharp',
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        title: "The cat sat on the mat",
        created_at: Time.parse("2019-05-15T15:20:33Z").utc,
        number: 1347,
        merged: false,
        merged_at: nil,
        merged_by_username: nil,
        state: 'open'
      }

      RestClient.unstub(:get)
      stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
        to_return(status: 200, body: [
          { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', user: { login: "reviewer71" },
            submitted_at: "2019-05-23T12:12:13Z" },
          { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI5', user: { login: "reviewer13" },
            submitted_at: "2019-05-24T10:56:29Z" }
        ].to_json, headers: { 'Content-Type' => 'application/json' })

      reviews = [
        { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4', reviewer_username: "reviewer71",
          submitted_at: Time.parse("2019-05-23T12:12:13Z").utc },
        { node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI5', reviewer_username: "reviewer13",
          submitted_at: Time.parse("2019-05-24T10:56:29Z").utc }
      ]

      User::ReputationToken::AwardForPullRequest.expects(:call).with(**pull_request_update.merge(reviews:))

      ProcessPullRequestUpdateJob.perform_now(**pull_request_update)
    end
  end

  %w[edited opened reopened].each do |action|
    test "reputation tokens are not awarded when action is #{action}" do
      RestClient.unstub(:get)
      stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
        to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      User::ReputationToken::AwardForPullRequest.expects(:call).never

      ProcessPullRequestUpdateJob.perform_now(
        action:,
        author: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        repo: 'exercism/fsharp',
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        title: "The cat sat on the mat",
        created_at: Time.parse("2019-05-15T15:20:33Z").utc,
        number: 1347,
        merged: false,
        merged_at: nil,
        merged_by: nil,
        state: 'open'
      )
    end
  end

  %w[closed edited opened reopened labeled unlabeled].each do |action|
    test "creates pull request when action is #{action}" do
      pull_request_update = {
        action:,
        author_username: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        repo: 'exercism/fsharp',
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        title: "The cat sat on the mat",
        created_at: Time.parse("2019-05-15T15:20:33Z").utc,
        number: 1347,
        merged: true,
        merged_at: Time.parse("2019-05-15T16:43:00Z").utc,
        merged_by_username: 'merger11',
        state: 'open'
      }

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

      ProcessPullRequestUpdateJob.perform_now(**pull_request_update)

      pr = Github::PullRequest.find_by(node_id: pull_request_update[:node_id])
      pull_request_update[:data] = pull_request_update.merge(reviews:)
      assert_equal pull_request_update[:node_id], pr.node_id
      assert_equal pull_request_update[:number], pr.number
      assert_equal pull_request_update[:title], pr.title
      assert_equal pull_request_update[:repo], pr.repo
      assert_equal pull_request_update[:author_username], pr.author_username
      assert_equal pull_request_update[:merged_by_username], pr.merged_by_username
      assert_equal pull_request_update[:data], pr.data
    end

    test "updates pull request when action is #{action}" do
      pull_request_update = {
        action:,
        author_username: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        repo: 'exercism/fsharp',
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        title: "The cat sat on the mat",
        created_at: Time.parse("2019-05-15T15:20:33Z").utc,
        number: 1347,
        merged: true,
        merged_at: Time.parse("2019-05-15T16:43:00Z").utc,
        merged_by_username: 'merger11',
        state: 'open'
      }

      RestClient.unstub(:get)
      stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
        to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      pr = create(:github_pull_request,
**pull_request_update.merge(reviews: []).slice(:node_id, :number, :title, :author_username, :merged_by_username, :repo, :data))

      ProcessPullRequestUpdateJob.perform_now(**pull_request_update.merge(title: "New title"))

      assert_equal "New title", pr.reload.title
    end
  end

  test "state is correct for closed and unmerged pull requests" do
    pull_request_update = {
      action: 'closed',
      author_username: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      title: "The cat sat on the mat",
      created_at: Time.parse("2019-05-15T15:20:33Z").utc,
      number: 1347,
      merged: false,
      merged_at: nil,
      merged_by_username: nil,
      state: 'closed'
    }

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    ProcessPullRequestUpdateJob.perform_now(**pull_request_update)

    pr = Github::PullRequest.find_by(node_id: pull_request_update[:node_id])
    assert_equal :closed, pr.state
  end

  test "state is correct for closed and merged pull requests" do
    pull_request_update = {
      action: 'closed',
      author_username: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      title: "The cat sat on the mat",
      created_at: Time.parse("2019-05-15T15:20:33Z").utc,
      number: 1347,
      merged: true,
      merged_at: Time.parse("2019-05-15T16:43:00Z").utc,
      merged_by_username: 'merger11',
      state: 'open'
    }

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    ProcessPullRequestUpdateJob.perform_now(**pull_request_update)

    pr = Github::PullRequest.find_by(node_id: pull_request_update[:node_id])
    assert_equal :merged, pr.state
  end

  test "state is correct for open pull requests" do
    pull_request_update = {
      action: 'opened',
      author_username: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      title: "The cat sat on the mat",
      created_at: Time.parse("2019-05-15T15:20:33Z").utc,
      number: 1347,
      merged: false,
      merged_at: nil,
      merged_by_username: nil,
      state: 'open'
    }

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?per_page=100").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    ProcessPullRequestUpdateJob.perform_now(**pull_request_update)

    pr = Github::PullRequest.find_by(node_id: pull_request_update[:node_id])
    assert_equal :open, pr.state
  end

  test "creates pull request reviews" do
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
          'Link': "<https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews?page=2&per_page=100>; rel=\"last\"",
          'Content-Type': 'application/json'
        }
      )

    ProcessPullRequestUpdateJob.perform_now(
      action: 'closed',
      author_username: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      title: "The cat sat on the mat",
      created_at: Time.parse("2019-05-15T15:20:33Z").utc,
      number: 1347,
      merged: false,
      merged_at: nil,
      merged_by_username: nil,
      state: 'open'
    )

    assert_equal 3, Github::PullRequestReview.find_each.size
  end
end

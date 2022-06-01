require "test_helper"

class Webhooks::ProcessPullRequestUpdateTest < ActiveSupport::TestCase
  test "should enqueue process pull request update when pr was closed" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/fsharp'
    number = 4

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      Webhooks::ProcessPullRequestUpdate.(
        action:, login:, url:, html_url:,
        labels:, state:, repo:, number:
      )
    end
  end

  test "should enqueue process pull request update when pr was labeled" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/fsharp'
    number = 4

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      Webhooks::ProcessPullRequestUpdate.(
        action:, login:, url:, html_url:,
        labels:, state:, repo:, number:
      )
    end
  end

  test "should enqueue process pull request update when pr was unlabeled" do
    action = 'unlabeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/fsharp'
    number = 4

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      Webhooks::ProcessPullRequestUpdate.(
        action:, login:, url:, html_url:,
        labels:, state:, repo:, number:
      )
    end
  end

  test "should not enqueue process pull request update when pr was opened" do
    action = 'opened'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/fsharp'
    number = 4

    assert_enqueued_jobs 0, only: ProcessPullRequestUpdateJob do
      Webhooks::ProcessPullRequestUpdate.(
        action:, login:, url:, html_url:,
        labels:, state:, repo:, number:
      )
    end
  end

  test "should not enqueue process pull request update when pr is open" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    state = 'open'
    repo = 'exercism/fsharp'
    number = 4

    assert_enqueued_jobs 0, only: ProcessPullRequestUpdateJob do
      Webhooks::ProcessPullRequestUpdate.(
        action:, login:, url:, html_url:,
        labels:, state:, repo:, number:
      )
    end
  end
end

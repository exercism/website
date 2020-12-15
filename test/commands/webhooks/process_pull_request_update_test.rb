require "test_helper"

class Webhooks::ProcessPullRequestUpdateTest < ActiveSupport::TestCase
  test "should enqueue process pull request update when pr was closed" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/v3'
    number = 4

    Webhooks::ProcessPullRequestUpdate.(action, login, url: url, html_url: html_url, labels: labels, state: state,
                                                       repo: repo, number: number)

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      ProcessPullRequestUpdateJob.perform_later(action, login, url: url, html_url: html_url, labels: labels)
    end
  end

  test "should enqueue process pull request update when pr was labeled" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/v3'
    number = 4

    Webhooks::ProcessPullRequestUpdate.(action, login, url: url, html_url: html_url, labels: labels, state: state,
                                                       repo: repo, number: number)

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      ProcessPullRequestUpdateJob.perform_later(action, login, url: url, html_url: html_url, labels: labels)
    end
  end

  test "should enqueue process pull request update when pr was unlabeled" do
    action = 'unlabeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/v3'
    number = 4

    Webhooks::ProcessPullRequestUpdate.(action, login, url: url, html_url: html_url, labels: labels, state: state,
                                                       repo: repo, number: number)

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      ProcessPullRequestUpdateJob.perform_later(action, login, url: url, html_url: html_url, labels: labels)
    end
  end

  test "should not enqueue process pull request update when pr was opened" do
    action = 'opened'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    state = 'closed'
    repo = 'exercism/v3'
    number = 4

    Webhooks::ProcessPullRequestUpdate.(action, login, url: url, html_url: html_url, labels: labels, state: state,
                                                       repo: repo, number: number)

    assert_enqueued_jobs 0, only: ProcessPullRequestUpdateJob
  end

  test "should not enqueue process pull request update when pr is open" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    state = 'open'
    repo = 'exercism/v3'
    number = 4

    Webhooks::ProcessPullRequestUpdate.(action, login, url: url, html_url: html_url, labels: labels, state: state,
                                                       repo: repo, number: number)

    assert_enqueued_jobs 0, only: ProcessPullRequestUpdateJob
  end
end

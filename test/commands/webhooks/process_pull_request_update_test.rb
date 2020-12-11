require "test_helper"

class Webhooks::ProcessPullRequestUpdateTest < ActiveSupport::TestCase
  test "should enqueue code contributions sync job when pr was closed" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'

    Webhooks::ProcessPullRequestUpdate.(action, login, url, html_url)

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      ProcessPullRequestUpdateJob.perform_later(action, login, url, html_url)
    end
  end

  test "should enqueue code contributions sync job when pr was labeled" do
    action = 'labeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'

    Webhooks::ProcessPullRequestUpdate.(action, login, url, html_url)

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      ProcessPullRequestUpdateJob.perform_later(action, login, url, html_url)
    end
  end

  test "should enqueue code contributions sync job when pr was unlabeled" do
    action = 'unlabeled'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'

    Webhooks::ProcessPullRequestUpdate.(action, login, url, html_url)

    assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
      ProcessPullRequestUpdateJob.perform_later(action, login, url, html_url)
    end
  end

  test "should enqueue code contributions sync job when pr was opened" do
    action = 'opened'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'

    Webhooks::ProcessPullRequestUpdate.(action, login, url, html_url)

    assert_enqueued_jobs 0, only: ProcessPullRequestUpdateJob
  end
end

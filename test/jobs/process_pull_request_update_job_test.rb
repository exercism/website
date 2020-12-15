require "test_helper"

class ProcessPullRequestUpdateJobTest < ActiveJob::TestCase
  test "reputation tokens are awarded for pull request" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]

    User::ReputationToken::AwardForPullRequest.expects(:call).with(action, login, url: url, html_url: html_url,
                                                                                  labels: labels)
    ProcessPullRequestUpdateJob.perform_now(action, login, url: url, html_url: html_url, labels: labels)
  end
end

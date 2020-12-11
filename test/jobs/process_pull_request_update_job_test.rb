require "test_helper"

class ProcessPullRequestUpdateJobTest < ActiveJob::TestCase
  test "reputation tokens are awarded for pull request" do
    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'

    User::ReputationToken::AwardForPullRequest.expects(:call).with(action, login, url, html_url)
    ProcessPullRequestUpdateJob.perform_now(action, login, url, html_url)
  end
end

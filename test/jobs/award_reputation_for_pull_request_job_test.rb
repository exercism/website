require "test_helper"

class AwardReputationForPullRequestJobTest < ActiveJob::TestCase
  test "sync pull requests reputation is called" do
    params = mock

    User::ReputationToken::AwardForPullRequest.expects(:call).with(params)

    AwardReputationForPullRequestJob.perform_now(params)
  end
end

require "test_helper"

class AwardReputationForUserPullRequestsJobTest < ActiveJob::TestCase
  test "sync pull requests reputation is called" do
    user = mock

    User::ReputationToken::AwardForPullRequestsForUser.expects(:call).with(user)

    AwardReputationForUserPullRequestsJob.perform_now(user)
  end
end

require "test_helper"

class AwardReputationToUserForPullRequestsJobTest < ActiveJob::TestCase
  test "sync pull requests reputation is called" do
    user = mock

    User::ReputationToken::AwardForPullRequestsForUser.expects(:call).with(user)

    AwardReputationToUserForPullRequestsJob.perform_now(user)
  end
end

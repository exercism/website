require "test_helper"

class AwardPullRequestReputationJobTest < ActiveJob::TestCase
  test "sync pull requests reputation is called" do
    user = mock

    Git::SyncPullRequestsReputationForUser.expects(:call).with(user)

    AwardPullRequestReputationJob.perform_now(user)
  end
end

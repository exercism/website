require "test_helper"

class SweepReputationPeriodsJobTest < ActiveJob::TestCase
  test "correct locks are cleared" do
    User::ReputationPeriod::Sweep.expects(:call)

    SweepReputationPeriodsJob.perform_now
  end
end

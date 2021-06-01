require "test_helper"

class SweepReputationPeriodsJobTest < ActiveJob::TestCase
  test "proxies to correct job" do
    User::ReputationPeriod::Sweep.expects(:call)

    SweepReputationPeriodsJob.perform_now
  end
end

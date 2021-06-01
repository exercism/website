require "test_helper"

class User::ReputationPeriod::SweepTest < ActiveJob::TestCase
  test "correct locks are cleared" do
    dirty_1 = create :user_reputation_period, :dirty
    dirty_2 = create :user_reputation_period, :dirty
    create :user_reputation_period
    User::ReputationPeriod::UpdateReputation.expects(:call).with(dirty_1)
    User::ReputationPeriod::UpdateReputation.expects(:call).with(dirty_2)

    User::ReputationPeriod::Sweep.()
  end
end

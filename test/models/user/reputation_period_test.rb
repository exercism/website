require "test_helper"

class User::ReputationPeriodTest < ActiveSupport::TestCase
  test "dirty scope" do
    dirty = create :user_reputation_period, :dirty
    clean = create :user_reputation_period

    assert_equal [dirty, clean], User::ReputationPeriod.all # Sanity
    assert_equal [dirty], User::ReputationPeriod.dirty
  end
end

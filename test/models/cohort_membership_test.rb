require "test_helper"

class CohortMembershipTest < ActiveSupport::TestCase
  test "status is symbolized" do
    membership = create :cohort_membership
    membership.status = :enrolled

    assert_equal :enrolled, membership.status
    assert membership.enrolled?
  end
end

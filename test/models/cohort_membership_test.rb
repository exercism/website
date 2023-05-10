require "test_helper"

class CohortMembershipTest < ActiveSupport::TestCase
  test "status is symbolized" do
    membership = create :cohort_membership
    membership.status = :enrolled

    assert_equal :enrolled, membership.status
    assert membership.enrolled?
  end

  test "position_on_waiting_list when on waiting list returns correct position" do
    user = create :user
    cohort = create :cohort, slug: 'gohort'
    other_cohort = create :cohort, slug: 'exhort'

    create(:cohort_membership, :on_waiting_list, cohort:)
    create(:cohort_membership, :on_waiting_list, cohort:)
    create(:cohort_membership, :on_waiting_list, cohort:)

    # Sanity check: enrollment in other cohort does not count
    create(:cohort_membership, :on_waiting_list, cohort: other_cohort, user:)

    membership = create(:cohort_membership, :on_waiting_list, cohort:, user:)

    assert_equal 4, membership.position_on_waiting_list
  end

  test "position_on_waiting_list when enrolled returns nil" do
    membership = create :cohort_membership, :enrolled

    assert_nil membership.position_on_waiting_list
  end
end

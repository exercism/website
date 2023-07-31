require "test_helper"

class CohortTest < ActiveSupport::TestCase
  test "members" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user

    cohort = create :cohort

    create :cohort_membership, cohort:, user: user_1
    create :cohort_membership, cohort:, user: user_2
    create :cohort_membership, cohort:, user: user_3

    assert_equal [user_1, user_2, user_3], cohort.members
  end

  test "can_be_joined?" do
    cohort = create :cohort, capacity: 3

    # Empty cohort can be joined
    assert cohort.can_be_joined?

    create(:cohort_membership, cohort:)
    create(:cohort_membership, cohort:)

    # Cohort just shy of capacity can be joined
    assert cohort.can_be_joined?

    create(:cohort_membership, cohort:)

    # Cohort at capacity cannot be joined
    refute cohort.can_be_joined?

    create(:cohort_membership, cohort:)

    # Cohort exceeding capacity cannot be joined
    refute cohort.can_be_joined?
  end
end

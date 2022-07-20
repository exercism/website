require "test_helper"

class Cohort::JoinTest < ActiveSupport::TestCase
  test "join cohort with open spots" do
    user = create :user
    cohort = create :cohort, capacity: 5
    introduction = 'Hi there'

    membership = Cohort::Join.(user, cohort, introduction)

    assert_equal user, membership.user
    assert_equal cohort, membership.cohort
    assert_equal :enrolled, membership.status
    assert_equal introduction, membership.introduction
  end

  test "join cohort without open spots" do
    user = create :user
    cohort = create :cohort, capacity: 5
    cohort.capacity.times do
      create :cohort_membership, cohort:
    end
    introduction = 'Hi there'

    membership = Cohort::Join.(user, cohort, introduction)

    assert_equal user, membership.user
    assert_equal cohort, membership.cohort
    assert_equal :on_waiting_list, membership.status
    assert_equal introduction, membership.introduction
  end

  test "idempotent" do
    user = create :user
    cohort = create :cohort

    assert_idempotent_command do
      Cohort::Join.(user, cohort, 'Hi')
    end

    assert_equal 1, CohortMembership.count
  end
end

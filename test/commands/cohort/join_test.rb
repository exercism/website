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

  test "join cohort properly escapes introduction" do
    user = create :user
    cohort = create :cohort, capacity: 5
    introduction = 'Hi "there"'

    membership = Cohort::Join.(user, cohort, introduction)

    assert_equal user, membership.user
    assert_equal cohort, membership.cohort
    assert_equal :enrolled, membership.status
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

  test "enrolled members never exceeds capacity" do
    cohort = create :cohort, capacity: 10
    member_count = cohort.capacity * 10
    users = create_list(:user, member_count)

    # We're testing that when multiple people try to join
    # at the same time, the number of enrolled members never
    # exceeds the cohort's capacity
    threads = Array.new(member_count) do |idx|
      Thread.new do
        Rails.application.executor.wrap do
          Cohort::Join.(users[idx], cohort, 'Hi')
        end
      end
    end
    threads.map(&:join)

    assert_equal member_count, CohortMembership.count
    assert_equal cohort.capacity, CohortMembership.enrolled.count
    assert_equal member_count - cohort.capacity, CohortMembership.on_waiting_list.count
  end
end

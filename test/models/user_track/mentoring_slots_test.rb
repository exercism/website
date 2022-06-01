require 'test_helper'

class User::MentoringSlotsTest < ActiveSupport::TestCase
  test "no rep" do
    user = create :user, reputation: 0
    user_track = create :user_track, user: user

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 0, user_track.num_used_mentoring_slots
    assert_equal 2, user_track.num_available_mentoring_slots
    assert_equal 0, user_track.percentage_to_next_mentoring_slot
    assert_equal 100, user_track.repo_for_next_mentoring_slot
  end

  test "between 2 and 3 slots" do
    user = create :user, reputation: 150
    user_track = create :user_track, user: user

    assert_equal 1, user_track.num_locked_mentoring_slots
    assert_equal 0, user_track.num_used_mentoring_slots
    assert_equal 3, user_track.num_available_mentoring_slots
    assert_equal 50 / 400.to_f * 100, user_track.percentage_to_next_mentoring_slot
    assert_equal 500, user_track.repo_for_next_mentoring_slot
  end

  test "all unlocked" do
    user = create :user, reputation: 550
    user_track = create :user_track, user: user

    assert_equal 0, user_track.num_locked_mentoring_slots
    assert_equal 0, user_track.num_used_mentoring_slots
    assert_equal 4, user_track.num_available_mentoring_slots
    assert_nil user_track.percentage_to_next_mentoring_slot
    assert_nil user_track.repo_for_next_mentoring_slot
    assert user_track.has_available_mentoring_slot?
  end

  test "with one used" do
    user = create :user, reputation: 0
    user_track = create :user_track, user: user
    solution = create :practice_solution, user: user, track: user_track.track
    create :mentor_request, solution: solution

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 1, user_track.num_used_mentoring_slots
    assert_equal 1, user_track.num_available_mentoring_slots
    assert user_track.has_available_mentoring_slot?
  end

  test "with both used" do
    user = create :user, reputation: 0
    user_track = create :user_track, user: user
    solution = create :practice_solution, user: user, track: user_track.track
    create :mentor_request, solution: solution
    create :mentor_discussion, solution: solution

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 2, user_track.num_used_mentoring_slots
    assert_equal 0, user_track.num_available_mentoring_slots
    refute user_track.has_available_mentoring_slot?
  end

  test "with negative number" do
    user = create :user, reputation: 0
    user_track = create :user_track, user: user
    5.times do
      solution = create :practice_solution, user: user, track: user_track.track
      create :mentor_request, solution:
    end

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 5, user_track.num_used_mentoring_slots
    assert_equal 0, user_track.num_available_mentoring_slots
    refute user_track.has_available_mentoring_slot?
  end
end

require 'test_helper'

class User::MentoringSlotsTest < ActiveSupport::TestCase
  test "no rep" do
    user = create :user, reputation: 0
    user_track = create(:user_track, user:)

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 0, user_track.num_used_mentoring_slots
    assert_equal 2, user_track.num_available_mentoring_slots
    assert_equal 0, user_track.percentage_to_next_mentoring_slot
    assert_equal 100, user_track.rep_for_next_mentoring_slot
  end

  test "between 2 and 3 slots" do
    user = create :user, reputation: 150
    user_track = create(:user_track, user:)

    assert_equal 1, user_track.num_locked_mentoring_slots
    assert_equal 0, user_track.num_used_mentoring_slots
    assert_equal 3, user_track.num_available_mentoring_slots
    assert_equal 50 / 400.to_f * 100, user_track.percentage_to_next_mentoring_slot
    assert_equal 500, user_track.rep_for_next_mentoring_slot
  end

  test "all unlocked" do
    user = create :user, reputation: 550
    user_track = create(:user_track, user:)

    assert_equal 0, user_track.num_locked_mentoring_slots
    assert_equal 0, user_track.num_used_mentoring_slots
    assert_equal 4, user_track.num_available_mentoring_slots
    assert_nil user_track.percentage_to_next_mentoring_slot
    assert_nil user_track.rep_for_next_mentoring_slot
    assert user_track.has_available_mentoring_slot?
  end

  test "insider" do
    user = create :user, :insider
    user_track = create(:user_track, user:)

    assert_equal 0, user_track.num_locked_mentoring_slots
    assert_equal 0, user_track.num_used_mentoring_slots
    assert_equal 4, user_track.num_available_mentoring_slots
    assert_nil user_track.percentage_to_next_mentoring_slot
    assert_nil user_track.rep_for_next_mentoring_slot
    assert user_track.has_available_mentoring_slot?
  end

  test "with one used" do
    user = create :user, reputation: 0
    user_track = create(:user_track, user:)
    solution = create :practice_solution, user:, track: user_track.track
    create(:mentor_request, solution:)

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 1, user_track.num_used_mentoring_slots
    assert_equal 1, user_track.num_available_mentoring_slots
    assert user_track.has_available_mentoring_slot?
  end

  test "with both used" do
    user = create :user, reputation: 0
    user_track = create(:user_track, user:)
    solution = create :practice_solution, user:, track: user_track.track
    create(:mentor_request, solution:)
    create(:mentor_discussion, solution:)

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 2, user_track.num_used_mentoring_slots
    assert_equal 0, user_track.num_available_mentoring_slots
    refute user_track.has_available_mentoring_slot?
  end

  test "with negative number" do
    user = create :user, reputation: 0
    user_track = create(:user_track, user:)
    5.times do
      solution = create :practice_solution, user:, track: user_track.track
      create :mentor_request, solution:
    end

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 5, user_track.num_used_mentoring_slots
    assert_equal 0, user_track.num_available_mentoring_slots
    refute user_track.has_available_mentoring_slot?
  end

  test "external discussions don't take up mentoring slots" do
    user = create :user, reputation: 0
    user_track = create(:user_track, user:)

    # Regular, non-external discussion
    solution = create(:practice_solution, user:)
    create(:mentor_discussion, solution:)

    # External discussions
    4.times do
      solution = create(:practice_solution, user:)
      create :mentor_discussion, :external, solution:
    end

    assert_equal 2, user_track.num_locked_mentoring_slots
    assert_equal 1, user_track.num_used_mentoring_slots
    assert_equal 1, user_track.num_available_mentoring_slots
  end
end

require 'test_helper'

class Mentor::Discussion::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves user's solutions" do
    user = create :user

    valid = create :mentor_discussion, :awaiting_mentor, mentor: user
    create :mentor_discussion, :awaiting_mentor

    assert_equal [valid], Mentor::Discussion::Retrieve.(user, :awaiting_mentor, page: 1)
  end

  test "status: awaiting_mentor" do
    user = create :user

    valid = create :mentor_discussion, :awaiting_mentor, mentor: user
    create :mentor_discussion, mentor: user

    assert_equal [valid], Mentor::Discussion::Retrieve.(user, :awaiting_mentor, page: 1)
  end

  test "status: awaiting_student" do
    user = create :user

    valid = create :mentor_discussion, :awaiting_student, mentor: user
    create :mentor_discussion, :awaiting_mentor, mentor: user

    assert_equal [valid], Mentor::Discussion::Retrieve.(user, :awaiting_student, page: 1)
  end

  test "status: finished" do
    user = create :user

    valid_1 = create :mentor_discussion, :mentor_finished, mentor: user
    valid_2 = create :mentor_discussion, :student_finished, mentor: user
    create :mentor_discussion, :awaiting_mentor, mentor: user
    create :mentor_discussion, :awaiting_student, mentor: user

    assert_equal [valid_2, valid_1], Mentor::Discussion::Retrieve.(user, :finished, page: 1)
  end

  test "only retrieves relevant tracks" do
    user = create :user
    ruby = create :track, slug: :ruby
    js = create :track, slug: :js
    elixir = create :track, slug: :elixir

    create :mentor_discussion, :awaiting_mentor, track: ruby, mentor: user
    create :mentor_discussion, :awaiting_mentor, track: elixir, mentor: user
    create :mentor_discussion, :awaiting_mentor, track: js

    assert_equal [elixir, ruby], Mentor::Discussion::Retrieve.(user, :awaiting_mentor).map(&:track)
    assert_equal [elixir, ruby], Mentor::Discussion::Retrieve.(user, :awaiting_mentor, track_slug: '').map(&:track)
    assert_equal [ruby], Mentor::Discussion::Retrieve.(user, :awaiting_mentor, track_slug: 'ruby').map(&:track)
  end

  test "ordering works" do
    user = create :user

    erik = create :user, handle: "erik"
    karlo = create :user, handle: "karlo"

    bob = create :practice_exercise, title: "bob"
    leap = create :practice_exercise, title: "leap"

    erik_bob_sol = create :practice_solution, user: erik, exercise: bob
    karlo_bob_sol = create :practice_solution, user: karlo, exercise: bob
    erik_leap_sol = create :practice_solution, user: erik, exercise: leap
    karlo_leap_sol = create :practice_solution, user: karlo, exercise: leap

    erik_leap = create :mentor_discussion, solution: erik_leap_sol, updated_at: Time.current - 4.minutes, mentor: user
    karlo_bob = create :mentor_discussion, solution: karlo_bob_sol, updated_at: Time.current - 5.minutes, mentor: user
    erik_bob = create :mentor_discussion, solution: erik_bob_sol, updated_at: Time.current - 1.minute, mentor: user
    karlo_leap = create :mentor_discussion, solution: karlo_leap_sol, updated_at: Time.current - 2.minutes, mentor: user

    # Unsorted defaults to recent first
    assert_equal [erik_bob, karlo_leap, erik_leap, karlo_bob], Mentor::Discussion::Retrieve.(user, :all)

    assert_equal [karlo_bob, erik_leap, karlo_leap, erik_bob], Mentor::Discussion::Retrieve.(user, :all, order: 'oldest')
    assert_equal [erik_bob, karlo_leap, erik_leap, karlo_bob], Mentor::Discussion::Retrieve.(user, :all, order: 'recent')
    assert_equal [erik_leap, erik_bob, karlo_bob, karlo_leap], Mentor::Discussion::Retrieve.(user, :all, order: 'student')
    assert_equal [karlo_bob, erik_bob, erik_leap, karlo_leap], Mentor::Discussion::Retrieve.(user, :all, order: 'exercise')
  end

  test "pagination works" do
    user = create :user

    25.times { create :mentor_discussion, :awaiting_mentor, mentor: user }

    requests = Mentor::Discussion::Retrieve.(user, :awaiting_mentor, page: 2)
    assert_equal 2, requests.current_page
    assert_equal 3, requests.total_pages
    assert_equal 10, requests.limit_value
    assert_equal 25, requests.total_count
  end

  test "returns relationship unless paginated" do
    mentored_track = create :track
    user = create :user

    solution = create :concept_solution, track: mentored_track

    create(:mentor_request, solution:)

    requests = Mentor::Discussion::Retrieve.(user, :awaiting_mentor, paginated: false)
    assert requests.is_a?(ActiveRecord::Relation)
    refute_respond_to requests, :current_page
  end

  test "filter by student" do
    mentor = create :user
    student_1 = create :user, handle: "bob"
    student_2 = create :user, handle: "bobby"
    student_3 = create :user, handle: "margaret"

    solution_1 = create :practice_solution, user: student_1
    solution_2 = create :practice_solution, user: student_2
    solution_3 = create :practice_solution, user: student_3

    discussion_1 = create(:mentor_discussion, :awaiting_mentor, solution: solution_1, mentor:)
    discussion_2 = create(:mentor_discussion, :awaiting_mentor, solution: solution_2, mentor:)
    discussion_3 = create(:mentor_discussion, :awaiting_mentor, solution: solution_3, mentor:)

    assert_equal [discussion_3, discussion_2, discussion_1], Mentor::Discussion::Retrieve.(mentor, :all) # Saniry
    assert_equal [discussion_1], Mentor::Discussion::Retrieve.(mentor, :all, student_handle: "bob")
  end

  test "filter by criteria" do
    mentor = create :user
    bob = create :user, handle: "bob"
    bobby = create :user, handle: "bobby"
    margaret = create :user, handle: "margaret"

    leap = create :practice_exercise, title: "leap"
    bowling = create :practice_exercise, title: "bowling"
    food_chain = create :practice_exercise, title: "food chain"

    bob_leap = create :practice_solution, user: bob, exercise: leap
    bob_bowling = create :practice_solution, user: bob, exercise: bowling
    bob_food_chain = create :practice_solution, user: bob, exercise: food_chain

    bobby_leap = create :practice_solution, user: bobby, exercise: leap
    bobby_bowling = create :practice_solution, user: bobby, exercise: bowling
    bobby_food_chain = create :practice_solution, user: bobby, exercise: food_chain

    margaret_leap = create :practice_solution, user: margaret, exercise: leap
    margaret_bowling = create :practice_solution, user: margaret, exercise: bowling
    margaret_food_chain = create :practice_solution, user: margaret, exercise: food_chain

    PracticeSolution.all.each do |solution|
      create :mentor_discussion, :awaiting_mentor, solution:, mentor:
    end

    assert_equal 9, Mentor::Discussion::Retrieve.(mentor, :all).size
    assert_equal [
      bob_leap, bob_bowling, bob_food_chain, bobby_leap, bobby_bowling, bobby_food_chain, margaret_bowling
    ], Mentor::Discussion::Retrieve.(mentor, :all, criteria: "bo").map(&:solution).sort
    assert_equal [
      margaret_leap, margaret_bowling, margaret_food_chain
    ], Mentor::Discussion::Retrieve.(mentor, :all, criteria: "mar").map(&:solution).sort
  end

  test "filter by exclude_uuid" do
    user = create :user

    discussion_1 = create :mentor_discussion, :mentor_finished, mentor: user
    discussion_2 = create :mentor_discussion, :student_finished, mentor: user

    assert_empty Mentor::Discussion::Retrieve.(user, :all, page: 1, exclude_uuid: [discussion_1.uuid, discussion_2.uuid])
    assert_equal [discussion_2], Mentor::Discussion::Retrieve.(user, :all, page: 1, exclude_uuid: discussion_1.uuid)
  end

  test "raises when status is invalid" do
    user = create :user
    status = :unknown

    assert_raises InvalidDiscussionStatusError do
      Mentor::Discussion::Retrieve.(user, status)
    end
  end

  test "raises when status is nil" do
    user = create :user
    status = nil

    assert_raises InvalidDiscussionStatusError do
      Mentor::Discussion::Retrieve.(user, status)
    end
  end
end

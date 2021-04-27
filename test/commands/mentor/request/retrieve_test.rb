require 'test_helper'

class Mentor::Request::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves unlocked pending solutions" do
    mentored_track = create :track
    mentor = create :user
    create :user_track_mentorship, user: mentor, track: mentored_track

    solution = create :concept_solution, track: mentored_track

    # Cancelled
    create :mentor_request, status: :cancelled, solution: solution

    # Fulfilled
    create :mentor_request, status: :fulfilled, solution: solution

    # Locked
    request = create :mentor_request, solution: solution
    create :mentor_request_lock, request: request

    expired = create :mentor_request, solution: solution
    pending = create :mentor_request, solution: solution
    locked_by_mentor = create :mentor_request
    create :mentor_request_lock, request: locked_by_mentor, locked_by: mentor

    assert_equal [expired, pending, locked_by_mentor], Mentor::Request::Retrieve.(mentor: mentor)
  end

  test "does not retrieve own solutions" do
    mentored_track = create :track
    user = create :user
    create :user_track_mentorship, user: user, track: mentored_track

    other_solution = create :concept_solution, track: mentored_track
    mentors_solution = create :concept_solution, track: mentored_track, user: user

    other_request = create :mentor_request, solution: other_solution
    create :mentor_request, solution: mentors_solution

    assert_equal [other_request], Mentor::Request::Retrieve.(mentor: user)
  end

  test "does not mentor-blocked solutions" do
    mentored_track = create :track
    mentor = create :user
    create :user_track_mentorship, user: mentor, track: mentored_track

    good_student = create :user
    naughty_student = create :user
    unhappy_student = create :user

    create :mentor_student_relationship, mentor: mentor, student: good_student
    create :mentor_student_relationship, mentor: mentor, student: naughty_student, blocked_by_mentor: true
    create :mentor_student_relationship, mentor: mentor, student: unhappy_student, blocked_by_student: true

    good_solution = create :concept_solution, track: mentored_track, user: good_student
    naughty_solution = create :concept_solution, track: mentored_track, user: naughty_student
    unhappy_solution = create :concept_solution, track: mentored_track, user: unhappy_student

    good_request = create :mentor_request, solution: good_solution
    create :mentor_request, solution: naughty_solution
    create :mentor_request, solution: unhappy_solution

    assert_equal [good_request], Mentor::Request::Retrieve.(mentor: mentor)
  end

  test "only retrieves mentored or selected tracks" do
    mentored_track_1 = create :track, :random_slug
    mentored_track_2 = create :track, :random_slug
    unmentored_track = create :track, :random_slug
    user = create :user
    create :user_track_mentorship, user: user, track: mentored_track_1
    create :user_track_mentorship, user: user, track: mentored_track_2

    mt_1_req = create :mentor_request, solution: create(:concept_solution, track: mentored_track_1)
    mt_2_req = create :mentor_request, solution: create(:concept_solution, track: mentored_track_2)
    create :mentor_request, solution: create(:concept_solution, track: unmentored_track)

    assert_equal [mt_1_req, mt_2_req], Mentor::Request::Retrieve.(mentor: user)
    assert_equal [mt_1_req], Mentor::Request::Retrieve.(mentor: user, track_slug: mentored_track_1.slug)
  end

  test "only retrieves relevant exercises from correct tracks" do
    user = create :user

    ruby = create :track, slug: "ruby"
    js = create :track, slug: "js"
    create :user_track_mentorship, user: user, track: ruby
    create :user_track_mentorship, user: user, track: js

    ruby_bob = create :concept_exercise, track: ruby, slug: "bob"
    js_bob = create :concept_exercise, track: js, slug: "bob"

    ruby_strings = create :concept_exercise, track: ruby, slug: "strings"
    js_strings = create :concept_exercise, track: js, slug: "strings"

    ruby_bob_req = create :mentor_request, solution: create(:concept_solution, exercise: ruby_bob)
    js_bob_req = create :mentor_request, solution: create(:concept_solution, exercise: js_bob)
    ruby_strings_req = create :mentor_request, solution: create(:concept_solution, exercise: ruby_strings)
    js_strings_req = create :mentor_request, solution: create(:concept_solution, exercise: js_strings)

    assert_equal [
      ruby_bob_req, js_bob_req,
      ruby_strings_req, js_strings_req
    ], Mentor::Request::Retrieve.(mentor: user) # Sanity
    assert_equal [ruby_bob_req],
      Mentor::Request::Retrieve.(mentor: user, track_slug: ruby.slug, exercise_slug: ruby_bob.slug)
  end

  test "search works" do
    mentored_track = create :track
    user = create :user
    create :user_track_mentorship, user: user, track: mentored_track

    bob = create :user, handle: "Bob"
    toby = create :user, handle: "Toby"
    martin = create :user, handle: "Martin"

    bobs = create :mentor_request, solution: create(:practice_solution, user: bob, track: mentored_track)
    tobys = create :mentor_request, solution: create(:practice_solution, user: toby, track: mentored_track)
    martins = create :mentor_request, solution: create(:practice_solution, user: martin, track: mentored_track)

    assert_equal [bobs, tobys, martins], Mentor::Request::Retrieve.(mentor: user)
    assert_equal [bobs, tobys], Mentor::Request::Retrieve.(mentor: user, criteria: "ob")
  end

  test "orders by recency" do
    mentored_track = create :track
    user = create :user
    create :user_track_mentorship, user: user, track: mentored_track

    solution = create :concept_solution, track: mentored_track

    second = create :mentor_request, created_at: Time.current - 2.minutes, solution: solution
    first = create :mentor_request, created_at: Time.current - 3.minutes, solution: solution
    third = create :mentor_request, created_at: Time.current - 1.minute, solution: solution

    assert_equal [first, second, third], Mentor::Request::Retrieve.(mentor: user)
    assert_equal [second, first, third], Mentor::Request::Retrieve.(mentor: user, sorted: false)
  end

  test "pagination works" do
    mentored_track = create :track
    user = create :user
    create :user_track_mentorship, user: user, track: mentored_track

    solution = create :concept_solution, track: mentored_track

    25.times { create :mentor_request, solution: solution }

    requests = Mentor::Request::Retrieve.(mentor: user, page: 2)
    assert_equal 2, requests.current_page
    assert_equal 3, requests.total_pages
    assert_equal 10, requests.limit_value
    assert_equal 25, requests.total_count
  end

  test "boosts by a function of reputation" do
    # TODO
    skip
  end

  test "returns relationship unless paginated" do
    mentored_track = create :track
    user = create :user
    create :user_track_mentorship, user: user, track: mentored_track

    solution = create :concept_solution, track: mentored_track

    create :mentor_request, solution: solution

    requests = Mentor::Request::Retrieve.(mentor: user, paginated: false)
    assert requests.is_a?(ActiveRecord::Relation)
    refute_respond_to requests, :current_page
  end
end

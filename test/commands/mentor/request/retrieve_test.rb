require 'test_helper'

class Mentor::Request::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves unlocked pending solutions" do
    mentored_track = create :track
    user = create :user

    solution = create :concept_solution, track: mentored_track

    # Cancelled
    create :mentor_request, status: :cancelled, solution: solution

    # Fulfilled
    create :mentor_request, status: :fulfilled, solution: solution

    # Locked
    create :mentor_request, locked_until: Time.current + 10.minutes, solution: solution

    expired = create :mentor_request, locked_until: Time.current - 10.minutes, solution: solution
    pending = create :mentor_request, solution: solution

    assert_equal [expired, pending], Mentor::Request::Retrieve.(mentor: user)
  end

  test "does not retrieve own solutions" do
    mentored_track = create :track
    user = create :user

    other_solution = create :concept_solution, track: mentored_track
    mentors_solution = create :concept_solution, track: mentored_track, user: user

    other_request = create :mentor_request, solution: other_solution
    create :mentor_request, solution: mentors_solution

    assert_equal [other_request], Mentor::Request::Retrieve.(mentor: user)
  end

  test "returns all solutions without mentor" do
    mentored_track = create :track
    user = create :user

    other_solution = create :concept_solution, track: mentored_track
    mentors_solution = create :concept_solution, track: mentored_track, user: user

    request_1 = create :mentor_request, solution: other_solution
    request_2 = create :mentor_request, solution: mentors_solution

    assert_equal [request_1, request_2], Mentor::Request::Retrieve.()
  end

  test "only retrieves relevant tracks" do
    good_track = create :track
    bad_track = create :track, slug: "js"
    user = create :user

    good = create :mentor_request, solution: create(:concept_solution, track: good_track)
    bad = create :mentor_request, solution: create(:concept_solution, track: bad_track)

    assert_equal [good, bad], Mentor::Request::Retrieve.(mentor: user) # Sanity
    assert_equal [good], Mentor::Request::Retrieve.(mentor: user, track_slug: good_track.slug)
  end

  test "only retrieves relevant exercises from correct tracks" do
    user = create :user

    ruby = create :track, slug: "ruby"
    js = create :track, slug: "js"
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
      Mentor::Request::Retrieve.(mentor: user, track_slug: ruby.slug, exercise_slugs: [ruby_bob.slug])
  end

  test "orders by recency" do
    mentored_track = create :track
    user = create :user

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

    solution = create :concept_solution, track: mentored_track

    create :mentor_request, solution: solution

    requests = Mentor::Request::Retrieve.(mentor: user, paginated: false)
    assert requests.is_a?(ActiveRecord::Relation)
    refute_respond_to requests, :current_page
  end
end

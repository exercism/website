require 'test_helper'

class Solution::MentorRequest::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves unlocked pending solutions" do
    mentored_track = create :track
    user = create :user

    solution = create :concept_solution, track: mentored_track

    # Cancelled
    create :solution_mentor_request, status: :cancelled, solution: solution

    # Fulfilled
    create :solution_mentor_request, status: :fulfilled, solution: solution

    # Locked
    create :solution_mentor_request, locked_until: Time.current + 10.minutes, solution: solution

    expired = create :solution_mentor_request, locked_until: Time.current - 10.minutes, solution: solution
    pending = create :solution_mentor_request, solution: solution

    assert_equal [expired, pending], Solution::MentorRequest::Retrieve.(user)
  end

  test "does not retrieve own solutions" do
    mentored_track = create :track
    user = create :user

    other_solution = create :concept_solution, track: mentored_track
    mentors_solution = create :concept_solution, track: mentored_track, user: user

    other_request = create :solution_mentor_request, solution: other_solution
    create :solution_mentor_request, solution: mentors_solution

    assert_equal [other_request], Solution::MentorRequest::Retrieve.(user)
  end

  test "only retrieves relevant tracks" do
    good_track = create :track
    bad_track = create :track, slug: "js"
    user = create :user

    good = create :solution_mentor_request, solution: create(:concept_solution, track: good_track)
    bad = create :solution_mentor_request, solution: create(:concept_solution, track: bad_track)

    assert_equal [good, bad], Solution::MentorRequest::Retrieve.(user) # Sanity
    assert_equal [good], Solution::MentorRequest::Retrieve.(user, track_slug: good_track.slug)
  end

  test "only retrieves relevant exercises from correct tracks" do
    user = create :user

    ruby = create :track, slug: "ruby"
    js = create :track, slug: "js"
    ruby_bob = create :concept_exercise, track: ruby, slug: "bob"
    js_bob = create :concept_exercise, track: js, slug: "bob"

    ruby_strings = create :concept_exercise, track: ruby, slug: "strings"
    js_strings = create :concept_exercise, track: js, slug: "strings"

    ruby_bob_req = create :solution_mentor_request, solution: create(:concept_solution, exercise: ruby_bob)
    js_bob_req = create :solution_mentor_request, solution: create(:concept_solution, exercise: js_bob)
    ruby_strings_req = create :solution_mentor_request, solution: create(:concept_solution, exercise: ruby_strings)
    js_strings_req = create :solution_mentor_request, solution: create(:concept_solution, exercise: js_strings)

    assert_equal [
      ruby_bob_req, js_bob_req,
      ruby_strings_req, js_strings_req
    ], Solution::MentorRequest::Retrieve.(user) # Sanity
    assert_equal [ruby_bob_req],
      Solution::MentorRequest::Retrieve.(user, track_slug: ruby.slug, exercise_slugs: [ruby_bob.slug])
  end

  test "orders by recency" do
    mentored_track = create :track
    user = create :user

    solution = create :concept_solution, track: mentored_track

    second = create :solution_mentor_request, created_at: Time.current - 2.minutes, solution: solution
    first = create :solution_mentor_request, created_at: Time.current - 3.minutes, solution: solution
    third = create :solution_mentor_request, created_at: Time.current - 1.minute, solution: solution

    assert_equal [first, second, third], Solution::MentorRequest::Retrieve.(user)
    assert_equal [second, first, third], Solution::MentorRequest::Retrieve.(user, sorted: false)
  end

  test "pagination works" do
    mentored_track = create :track
    user = create :user

    solution = create :concept_solution, track: mentored_track

    25.times { create :solution_mentor_request, solution: solution }

    requests = Solution::MentorRequest::Retrieve.(user, page: 2)
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

    create :solution_mentor_request, solution: solution

    requests = Solution::MentorRequest::Retrieve.(user, paginated: false)
    assert requests.is_a?(ActiveRecord::Relation)
    refute_respond_to requests, :current_page
  end
end

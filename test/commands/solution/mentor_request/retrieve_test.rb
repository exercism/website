require 'test_helper'

class Mentor::QueueTest < ActiveSupport::TestCase
  setup do
    @mentored_track = create :track
    @user = create :user
  end

  test "only retrieves unlocked pending solutions" do
    solution = create :concept_solution, track: @mentored_track

    # Fulfilled
    create :solution_mentor_request, status: :cancelled, solution: solution

    # Cancelled
    create :solution_mentor_request, status: :fulfilled, solution: solution

    # Locked
    create :solution_mentor_request, locked_until: Time.current + 10.minutes, solution: solution

    expired = create :solution_mentor_request, locked_until: Time.current - 10.minutes, solution: solution
    pending = create :solution_mentor_request, solution: solution

    assert_equal [expired, pending], Solution::MentorRequest::Retrieve.(@user, 1)
  end

  test "does not retrieve own solutions" do
    other_solution = create :concept_solution, track: @mentored_track
    mentors_solution = create :concept_solution, track: @mentored_track, user: @user

    other_request = create :solution_mentor_request, solution: other_solution
    create :solution_mentor_request, solution: mentors_solution

    assert_equal [other_request], Solution::MentorRequest::Retrieve.(@user, 1)
  end

  test "only retrieves relevent tracks" do
    # TODO
    skip
  end

  test "orders by recency" do
    solution = create :concept_solution, track: @mentored_track

    second = create :solution_mentor_request, created_at: Time.current - 2.minutes, solution: solution
    first = create :solution_mentor_request, created_at: Time.current - 3.minutes, solution: solution
    third = create :solution_mentor_request, created_at: Time.current - 1.minute, solution: solution

    assert_equal [first, second, third], Solution::MentorRequest::Retrieve.(@user, 1)
  end

  test "pagination works" do
    solution = create :concept_solution, track: @mentored_track

    25.times { create :solution_mentor_request, solution: solution }

    requests = Solution::MentorRequest::Retrieve.(@user, 2)
    assert_equal 2, requests.current_page
    assert_equal 3, requests.total_pages
    assert_equal 10, requests.limit_value
    assert_equal 25, requests.total_count
  end

  test "boosts by a function of reputation" do
    # TODO
    skip
  end
end

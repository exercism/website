require "test_helper"

class Solution::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    user = create :user
    solution_1 = create :concept_solution, user: user
    solution_2 = create :practice_solution, user: user

    # Someone else's solution
    create :concept_solution

    assert_equal [solution_1, solution_2], Solution::Search.(user)
  end

  test "criteria" do
    user = create :user
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby_bob = create :concept_exercise, title: "Bob", track: ruby
    ruby_food = create :concept_exercise, title: "Food Chain", track: ruby
    js_bob = create :concept_exercise, title: "Bob", track: javascript

    ruby_bob_solution = create :concept_solution, user: user, exercise: ruby_bob
    ruby_food_solution = create :concept_solution, user: user, exercise: ruby_food
    js_bob_solution = create :practice_solution, user: user, exercise: js_bob

    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::Search.(user)
    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::Search.(user, criteria: " ")
    assert_equal [ruby_bob_solution, ruby_food_solution], Solution::Search.(user, criteria: "ru")
    assert_equal [ruby_bob_solution, js_bob_solution], Solution::Search.(user, criteria: "bo")
    assert_equal [ruby_bob_solution], Solution::Search.(user, criteria: "r bo")
  end

  test "status" do
    user = create :user
    in_progress = create :concept_solution, user: user
    completed = create :practice_solution, user: user, completed_at: Time.current
    published = create :practice_solution, user: user, completed_at: Time.current, published_at: Time.current

    assert_equal [in_progress, completed, published], Solution::Search.(user, status: nil)
    assert_equal [in_progress], Solution::Search.(user, status: :in_progress)
    assert_equal [in_progress], Solution::Search.(user, status: 'in_progress')
    assert_equal [completed, published], Solution::Search.(user, status: :all_completed)
    assert_equal [completed, published], Solution::Search.(user, status: 'all_completed')
    assert_equal [published], Solution::Search.(user, status: :published)
    assert_equal [published], Solution::Search.(user, status: 'published')
    assert_equal [completed], Solution::Search.(user, status: :not_published)
    assert_equal [completed], Solution::Search.(user, status: 'not_published')
  end

  test "mentoring_status" do
    user = create :user
    none = create :concept_solution, user: user, mentoring_status: :none
    requested = create :concept_solution, user: user, mentoring_status: :requested
    in_progress = create :concept_solution, user: user, mentoring_status: :in_progress
    completed = create :concept_solution, user: user, mentoring_status: :completed

    assert_equal [none, requested, in_progress, completed], Solution::Search.(user, mentoring_status: nil)

    assert_equal [none], Solution::Search.(user, mentoring_status: :none)
    assert_equal [none], Solution::Search.(user, mentoring_status: 'none')

    assert_equal [requested], Solution::Search.(user, mentoring_status: :requested)
    assert_equal [requested], Solution::Search.(user, mentoring_status: 'requested')

    assert_equal [in_progress], Solution::Search.(user, mentoring_status: :in_progress)
    assert_equal [in_progress], Solution::Search.(user, mentoring_status: 'in_progress')

    assert_equal [completed], Solution::Search.(user, mentoring_status: :completed)
    assert_equal [completed], Solution::Search.(user, mentoring_status: 'completed')
  end

  test "pagination" do
    user = create :user
    solution_1 = create :concept_solution, user: user
    solution_2 = create :concept_solution, user: user

    assert_equal [solution_1], Solution::Search.(user, page: 1, per: 1)
    assert_equal [solution_2], Solution::Search.(user, page: 2, per: 1)
    assert_equal [solution_1, solution_2], Solution::Search.(user, page: 1, per: 2)
    assert_equal [], Solution::Search.(user, page: 2, per: 2)
  end

  test "sort oldest first" do
    user = create :user
    solution_1 = create :concept_solution, user: user, created_at: 2.days.ago
    solution_2 = create :concept_solution, user: user, created_at: 1.day.ago

    assert_equal [solution_1, solution_2], Solution::Search.(user, sort: "oldest_first")
  end

  test "sort newest first" do
    user = create :user
    solution_1 = create :concept_solution, user: user, created_at: 1.day.ago
    solution_2 = create :concept_solution, user: user, created_at: 2.days.ago

    assert_equal [solution_1, solution_2], Solution::Search.(user, sort: "newest_first")
  end
end

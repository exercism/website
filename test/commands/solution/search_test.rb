require "test_helper"

class Solution::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    user = create :user
    solution_1 = create :concept_solution, user: user
    solution_2 = create :practice_solution, user: user

    # Someone else's solution
    create :concept_solution

    assert_equal [solution_2, solution_1], Solution::Search.(user)
  end

  test "criteria" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby"
    js_bob = create :concept_exercise, title: "Bob", track: javascript
    ruby_food = create :concept_exercise, title: "Food Chain", track: ruby
    ruby_bob = create :concept_exercise, title: "Bob", track: ruby

    js_bob_solution = create :practice_solution, user: user, exercise: js_bob
    ruby_food_solution = create :concept_solution, user: user, exercise: ruby_food
    ruby_bob_solution = create :concept_solution, user: user, exercise: ruby_bob

    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::Search.(user)
    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::Search.(user, criteria: " ")
    assert_equal [ruby_bob_solution, ruby_food_solution], Solution::Search.(user, criteria: "ru")
    assert_equal [ruby_bob_solution, js_bob_solution], Solution::Search.(user, criteria: "bo")
    assert_equal [ruby_bob_solution], Solution::Search.(user, criteria: "r bo")
  end

  test "status" do
    user = create :user
    published = create :practice_solution, user: user, completed_at: Time.current, published_at: Time.current
    completed = create :practice_solution, user: user, completed_at: Time.current
    in_progress = create :concept_solution, user: user

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
    completed = create :concept_solution, user: user, mentoring_status: :completed
    in_progress = create :concept_solution, user: user, mentoring_status: :in_progress
    requested = create :concept_solution, user: user, mentoring_status: :requested
    none = create :concept_solution, user: user, mentoring_status: :none

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

    assert_equal [solution_2], Solution::Search.(user, page: 1, per: 1)
    assert_equal [solution_1], Solution::Search.(user, page: 2, per: 1)
    assert_equal [solution_2, solution_1], Solution::Search.(user, page: 1, per: 2)
    assert_equal [], Solution::Search.(user, page: 2, per: 2)

    # Check it uses defaults for invalid values
    assert_equal [solution_2, solution_1], Solution::Search.(user, page: 0, per: 0)
    assert_equal [solution_2, solution_1], Solution::Search.(user, page: 'foo', per: 'bar')
  end

  test "sort oldest first" do
    user = create :user
    old_solution = create :concept_solution, user: user
    new_solution = create :concept_solution, user: user

    assert_equal [old_solution, new_solution], Solution::Search.(user, order: "oldest_first")
  end

  test "sort newest first by default" do
    user = create :user
    old_solution = create :concept_solution, user: user
    new_solution = create :concept_solution, user: user

    assert_equal [new_solution, old_solution], Solution::Search.(user)
  end
end

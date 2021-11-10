require "test_helper"

class Solution::SearchUserSolutionsTest < ActiveSupport::TestCase
  test "fallback is called" do
    user = create :user
    Solution::SearchUserSolutions::Fallback.expects(:call).with(user, page: 2, per: 15, track_slug: "csharp", status: "published",
mentoring_status: "none", criteria: "foobar", order: "oldest_first")
    Elasticsearch::Client.expects(:new).raises

    Solution::SearchUserSolutions.(user, page: 2, per: 15, track_slug: "csharp", status: "published", mentoring_status: "none",
criteria: "foobar", order: "oldest_first")
  end

  test "fallback: no options returns everything" do
    user = create :user
    solution_1 = create :concept_solution, user: user
    solution_2 = create :practice_solution, user: user

    # Someone else's solution
    create :concept_solution

    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions::Fallback.(user)
  end

  test "fallback: criteria" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby"
    js_bob = create :concept_exercise, title: "Bob", track: javascript
    ruby_food = create :concept_exercise, title: "Food Chain", track: ruby
    ruby_bob = create :concept_exercise, title: "Bob", track: ruby

    js_bob_solution = create :practice_solution, user: user, exercise: js_bob
    ruby_food_solution = create :concept_solution, user: user, exercise: ruby_food
    ruby_bob_solution = create :concept_solution, user: user, exercise: ruby_bob

    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::SearchUserSolutions::Fallback.(user)
    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::SearchUserSolutions::Fallback.(user, criteria: " ") # rubocop:disable Layout:LineLength
    assert_equal [ruby_bob_solution, ruby_food_solution], Solution::SearchUserSolutions::Fallback.(user, criteria: "ru")
    assert_equal [ruby_bob_solution, js_bob_solution], Solution::SearchUserSolutions::Fallback.(user, criteria: "bo")
    assert_equal [ruby_bob_solution].map(&:track), Solution::SearchUserSolutions::Fallback.(user, criteria: "ru bo").map(&:track)
    assert_equal [ruby_food_solution], Solution::SearchUserSolutions::Fallback.(user, criteria: "r ch fo")
  end

  test "fallback: track_slug" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'
    ruby_exercise = create :practice_exercise, track: ruby
    js_exercise = create :practice_exercise, track: javascript
    elixir_exercise = create :practice_exercise, track: elixir

    ruby_solution = create :practice_solution, user: user, exercise: ruby_exercise
    js_solution = create :practice_solution, user: user, exercise: js_exercise
    elixir_solution = create :practice_solution, user: user, exercise: elixir_exercise

    assert_equal [elixir_solution, js_solution, ruby_solution], Solution::SearchUserSolutions::Fallback.(user)
    assert_equal [js_solution, ruby_solution], Solution::SearchUserSolutions::Fallback.(user, track_slug: %i[ruby javascript])
    assert_equal [ruby_solution], Solution::SearchUserSolutions::Fallback.(user, track_slug: "ruby")
  end

  test "fallback: status" do
    user = create :user
    published = create :practice_solution, user: user, status: :published
    completed = create :practice_solution, user: user, status: :completed
    iterated = create :concept_solution, user: user, status: :iterated

    assert_equal [iterated, completed, published], Solution::SearchUserSolutions::Fallback.(user, status: nil)
    assert_equal [iterated], Solution::SearchUserSolutions::Fallback.(user, status: :iterated)
    assert_equal [iterated], Solution::SearchUserSolutions::Fallback.(user, status: 'iterated')
    assert_equal [completed, published], Solution::SearchUserSolutions::Fallback.(user, status: %i[completed published])
    assert_equal [completed, published], Solution::SearchUserSolutions::Fallback.(user, status: %w[completed published])
    assert_equal [published], Solution::SearchUserSolutions::Fallback.(user, status: :published)
    assert_equal [published], Solution::SearchUserSolutions::Fallback.(user, status: 'published')
  end

  test "fallback: mentoring_status" do
    user = create :user
    finished = create :concept_solution, user: user, mentoring_status: :finished
    in_progress = create :concept_solution, user: user, mentoring_status: :in_progress
    requested = create :concept_solution, user: user, mentoring_status: :requested
    none = create :concept_solution, user: user, mentoring_status: :none

    assert_equal [none, requested, in_progress, finished], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: nil)

    assert_equal [none], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: :none)
    assert_equal [none], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: 'none')

    assert_equal [requested], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: :requested)
    assert_equal [requested], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: 'requested')

    assert_equal [in_progress], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: :in_progress)
    assert_equal [in_progress], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: 'in_progress')

    assert_equal [finished], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: :finished)
    assert_equal [finished], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: 'finished')

    assert_equal [none, finished], Solution::SearchUserSolutions::Fallback.(user, mentoring_status: [:none, 'finished'])
  end

  test "fallback: pagination" do
    user = create :user
    solution_1 = create :concept_solution, user: user
    solution_2 = create :concept_solution, user: user

    assert_equal [solution_2], Solution::SearchUserSolutions::Fallback.(user, page: 1, per: 1)
    assert_equal [solution_1], Solution::SearchUserSolutions::Fallback.(user, page: 2, per: 1)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions::Fallback.(user, page: 1, per: 2)
    assert_empty Solution::SearchUserSolutions::Fallback.(user, page: 2, per: 2)
  end

  test "fallback: pagination with invalid values" do
    user = create :user
    solution_1 = create :concept_solution, user: user
    solution_2 = create :concept_solution, user: user
    Elasticsearch::Client.expects(:new).twice.raises

    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, page: 0, per: 0)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, page: 'foo', per: 'bar')
  end

  test "fallback: sort oldest first" do
    user = create :user
    old_solution = create :concept_solution, user: user
    new_solution = create :concept_solution, user: user

    assert_equal [old_solution, new_solution], Solution::SearchUserSolutions::Fallback.(user, order: "oldest_first")
  end

  test "fallback: sort newest first by default" do
    user = create :user
    old_solution = create :concept_solution, user: user
    new_solution = create :concept_solution, user: user

    assert_equal [new_solution, old_solution], Solution::SearchUserSolutions::Fallback.(user)
  end
end

require "test_helper"

class Solution::SearchFavoritesTest < ActiveSupport::TestCase
  test "no options returns all starred" do
    user = create :user
    solution_1 = create :practice_solution
    solution_2 = create :practice_solution

    create(:solution_star, user: user, solution: solution_1)

    # Different user should be ignored
    create(:solution_star, user: create(:user), solution: solution_2)

    assert_equal [solution_1], Solution::SearchFavorites.(user)
  end

  test "criteria: search for user handle" do
    user = create :user
    user_1 = create :user, handle: 'amy'
    user_2 = create :user, handle: 'chris'
    solution_1 = create :practice_solution, user: user_1
    solution_2 = create :practice_solution, user: user_2

    create :solution_star, user: user, solution: solution_1
    create :solution_star, user: user, solution: solution_2

    assert_equal [solution_1, solution_2], Solution::SearchFavorites.(user, criteria: "")
    assert_equal [solution_1], Solution::SearchFavorites.(user, criteria: "am")
    assert_equal [solution_2], Solution::SearchFavorites.(user, criteria: "chri")
  end

  test "track" do
    user = create :user
    track_1 = create :track, slug: "ruby"
    track_2 = create :track, slug: "javascript"
    exercise_1 = create :practice_exercise, track: track_1
    exercise_2 = create :practice_exercise, track: track_2
    solution_1 = create :practice_solution, exercise: exercise_1
    solution_2 = create :practice_solution, exercise: exercise_2

    create :solution_star, user: user, solution: solution_1
    create :solution_star, user: user, solution: solution_2

    assert_equal [solution_1, solution_2], Solution::SearchFavorites.(user, track_slug: "")
    assert_equal [solution_1, solution_2], Solution::SearchFavorites.(user, track_slug: "foo")
    assert_equal [solution_1], Solution::SearchFavorites.(user, track_slug: "ruby")
    assert_equal [solution_2], Solution::SearchFavorites.(user, track_slug: "javascript")
  end

  test "pagination" do
    user = create :user
    solution_1 = create :practice_solution
    solution_2 = create :practice_solution
    create :solution_star, user: user, solution: solution_1
    create :solution_star, user: user, solution: solution_2

    assert_equal [solution_1], Solution::SearchFavorites.(user, page: 1, per: 1)
    assert_equal [solution_2], Solution::SearchFavorites.(user, page: 2, per: 1)
  end
end

require "test_helper"

class Solution::SearchCommunitySolutionsTest < ActiveSupport::TestCase
  test "no options returns all published" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current

    # Unpublished
    create :concept_solution, exercise: exercise

    # A different exercise
    create :concept_solution

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise)
  end

  test "orders by stars then id" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 1
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 2
    solution_3 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 1

    assert_equal [solution_2, solution_3, solution_1], Solution::SearchCommunitySolutions.(exercise)
  end

  test "pagination" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current

    assert_equal [solution_2], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 1)
    assert_equal [solution_1], Solution::SearchCommunitySolutions.(exercise, page: 2, per: 1)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 2)
    assert_empty Solution::SearchCommunitySolutions.(exercise, page: 2, per: 2)

    # Check it uses defaults for invalid values
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, page: 0, per: 0)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, page: 'foo', per: 'bar')
  end
end

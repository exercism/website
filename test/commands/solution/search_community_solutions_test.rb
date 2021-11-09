require "test_helper"

class Solution::SearchCommunitySolutionsTest < ActiveSupport::TestCase
  test "fallback is called" do
    exercise = create :concept_exercise
    Solution::SearchCommunitySolutions::Fallback.expects(:call).with(exercise, 2, 15, "foobar")
    Elasticsearch::Client.expects(:new).raises

    Solution::SearchCommunitySolutions.(exercise, page: 2, per: 15, criteria: "foobar")
  end

  test "fallback: no options returns all published" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current

    # Unpublished
    create :concept_solution, exercise: exercise

    # A different exercise
    create :concept_solution

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 10, "")
  end

  test "fallback: orders by stars then id" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 1
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 2
    solution_3 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 1

    assert_equal [solution_2, solution_3, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 10, "")
  end

  test "fallback: pagination" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current

    assert_equal [solution_2], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 1, "")
    assert_equal [solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 1, "")
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 2, "")
    assert_empty Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 2, "")
  end
end

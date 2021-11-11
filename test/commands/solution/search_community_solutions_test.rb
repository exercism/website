require "test_helper"

class Solution::SearchCommunitySolutionsTest < ActiveSupport::TestCase
  SOLUTIONS_INDEX = 'test-solutions'.freeze

  setup do
    reset_opensearch!
  end

  test "no options returns all published" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    # Unpublished
    create :concept_solution, exercise: exercise

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 10, criteria: "")
  end

  test "orders by stars then id" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 1
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 2
    solution_3 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 1

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_3, solution_1], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 10, criteria: "")
  end

  test "pagination" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 1, criteria: "")
    assert_equal [solution_1], Solution::SearchCommunitySolutions.(exercise, page: 2, per: 1, criteria: "")
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 2, criteria: "")
    assert_empty Solution::SearchCommunitySolutions.(exercise, page: 2, per: 2, criteria: "")
  end

  test "fallback is called" do
    exercise = create :concept_exercise
    Solution::SearchCommunitySolutions::Fallback.expects(:call).with(exercise, 2, 15, "foobar")
    Elasticsearch::Client.expects(:new).raises

    Solution::SearchCommunitySolutions.(exercise, page: 2, per: 15, criteria: "foobar")
  end

  test "fallback: no options returns all published" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published

    # Unpublished
    create :concept_solution, exercise: exercise

    # A different exercise
    create :concept_solution

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 10, "")
  end

  test "fallback: orders by stars then id" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 1
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 2
    solution_3 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 1

    assert_equal [solution_2, solution_3, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 10, "")
  end

  test "fallback: pagination" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published

    assert_equal [solution_2], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 1, "")
    assert_equal [solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 1, "")
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 2, "")
    assert_empty Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 2, "")
  end
end

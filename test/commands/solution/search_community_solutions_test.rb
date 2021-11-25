require "test_helper"

class Solution::SearchCommunitySolutionsTest < ActiveSupport::TestCase
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

    assert_equal [solution_2, solution_1],
      Solution::SearchCommunitySolutions.(exercise, page: 1, per: 10, criteria: "", status: nil, mentoring_status: nil,
up_to_date: nil)
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

    assert_equal [solution_2, solution_3, solution_1],
      Solution::SearchCommunitySolutions.(exercise, page: 1, per: 10, criteria: "", status: nil, mentoring_status: nil,
up_to_date: nil)
  end

  test "pagination" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2],
      Solution::SearchCommunitySolutions.(exercise, page: 1, per: 1, criteria: "", status: nil, mentoring_status: nil, up_to_date: nil)
    assert_equal [solution_1],
      Solution::SearchCommunitySolutions.(exercise, page: 2, per: 1, criteria: "", status: nil, mentoring_status: nil, up_to_date: nil)
    assert_equal [solution_2, solution_1],
      Solution::SearchCommunitySolutions.(exercise, page: 1, per: 2, criteria: "", status: nil, mentoring_status: nil, up_to_date: nil)
    assert_empty Solution::SearchCommunitySolutions.(exercise, page: 2, per: 2, criteria: "", status: nil, mentoring_status: nil,
up_to_date: nil)
  end

  test "does not try and access values above 10_000" do
    # Don't do any checking in DB or ES
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never
    Exercism.expects(:opensearch_client).never

    results = Solution::SearchCommunitySolutions.(create(:concept_exercise), page: 1001, per: 10)
    assert_empty results
  end

  test "pagination returns max of 10_000 results" do
    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    data = { "hits" => { "hits" => [], "total" => { "value" => 10_001 } } }
    os_client = mock
    os_client.expects(:search).returns(data)
    Exercism.expects(:opensearch_client).returns(os_client)

    results = Solution::SearchCommunitySolutions.(create(:concept_exercise))
    assert_equal 10_000, results.total_count
  end

  test "fallback is called" do
    exercise = create :concept_exercise
    Solution::SearchCommunitySolutions::Fallback.expects(:call).with(exercise, 2, 15, "foobar", :active, :requested, true)
    Elasticsearch::Client.expects(:new).raises

    Solution::SearchCommunitySolutions.(exercise, page: 2, per: 15, criteria: "foobar", status: :active, mentoring_status: :requested,
up_to_date: true)
  end

  test "fallback is called when elasticsearch times out" do
    # Simulate a timeout
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Solution::SearchCommunitySolutions.any_instance.stubs(:search_query).returns({
        query: {
          function_score: {
            script_score: {
              script: {
                lang: "painless",
                source: "long total = 0; for (int i = 0; i < 500000; ++i) { total += i; } return total;"
              }
            }
          }
        }
      })
    end

    exercise = create :concept_exercise
    Solution::SearchCommunitySolutions::Fallback.expects(:call).with(exercise, 2, 15, "foobar")

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

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 10, "", nil, nil, nil)
  end

  test "fallback: orders by stars then id" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 1
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 2
    solution_3 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published, num_stars: 1

    assert_equal [solution_2, solution_3, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 10, "", nil, nil, nil)
  end

  test "fallback: pagination" do
    track = create :track
    exercise = create :concept_exercise, track: track
    solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, status: :published

    assert_equal [solution_2], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 1, "", nil, nil, nil)
    assert_equal [solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 1, "", nil, nil, nil)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 2, "", nil, nil, nil)
    assert_empty Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 2, "", nil, nil, nil)
  end
end

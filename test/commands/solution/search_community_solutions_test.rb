require "test_helper"

class Solution::SearchCommunitySolutionsTest < ActiveSupport::TestCase
  test "no options returns all published" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise)
  end

  test "criteria: search for user handle" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    user_1 = create :user, handle: 'amy'
    user_2 = create :user, handle: 'chris'
    solution_1 = create :concept_solution, exercise:, user: user_1, num_stars: 11, published_at: Time.current,
      status: :published
    solution_2 = create :concept_solution, exercise:, user: user_2, num_stars: 22, published_at: Time.current,
      status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, criteria: nil)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, criteria: "")
    assert_equal [solution_1], Solution::SearchCommunitySolutions.(exercise, criteria: "amy")
    assert_equal [solution_2], Solution::SearchCommunitySolutions.(exercise, criteria: "ris")
  end

  test "criteria: search for published iteration code" do
    # TODO: enable once we allow searching for code
    skip
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, published_at: Time.current, status: :published
    submission_1 = create :submission, solution: solution_1
    iteration_1 = create :iteration, solution: solution_1, submission: submission_1
    submission_file_1 = create :submission_file, submission: submission_1
    solution_2 = create :concept_solution, exercise:, published_at: Time.current, status: :published
    submission_2 = create :submission, solution: solution_2
    iteration_2 = create :iteration, solution: solution_2, submission: submission_2
    submission_file_2 = create :submission_file, submission: submission_2

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    # Overwrite the content
    upload_to_s3(submission_file_1.s3_bucket, submission_file_1.s3_key, 'let foo = 20')
    upload_to_s3(submission_file_2.s3_bucket, submission_file_2.s3_key, 'let bar = 30')
    solution_1.update!(published_iteration: iteration_1)
    solution_2.update!(published_iteration: iteration_2)

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2], Solution::SearchCommunitySolutions.(exercise, criteria: "bar")
  end

  test "filter: tests_status" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published
    submission_1 = create :submission, solution: solution_1
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published
    submission_2 = create :submission, solution: solution_2
    solution_3 = create :concept_solution, exercise:, num_stars: 33, published_at: Time.current, status: :published
    submission_3 = create :submission, solution: solution_3
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3, submission: submission_3))

    # We have to set these via the update_column so they don't get
    # overriden by all the processes that kick off
    perform_enqueued_jobs
    submission_1.reload.update_column(:tests_status, :passed)
    submission_2.reload.update_column(:tests_status, :passed)
    submission_3.reload.update_column(:tests_status, :failed)

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_3, solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, tests_status: nil)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, tests_status: :passed)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, tests_status: "passed")
    assert_equal [solution_3], Solution::SearchCommunitySolutions.(exercise, tests_status: :failed)
    assert_empty Solution::SearchCommunitySolutions.(exercise, tests_status: :errored)
    assert_equal [solution_3, solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, tests_status: %i[passed failed])
    assert_equal [solution_3, solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, tests_status: "passed failed")
  end

  test "filter: head_tests_status" do
    # If we let this run it will override the solutions below
    Solution::QueueHeadTestRun.stubs(:defer)

    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published,
      published_iteration_head_tests_status: :passed
    submission_1 = create :submission, solution: solution_1, tests_status: :passed
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published,
      published_iteration_head_tests_status: :passed
    submission_2 = create :submission, solution: solution_2, tests_status: :passed
    solution_3 = create :concept_solution, exercise:, num_stars: 33, published_at: Time.current, status: :published,
      published_iteration_head_tests_status: :errored
    submission_3 = create :submission, solution: solution_3, tests_status: :failed
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3, submission: submission_3))

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_3, solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, head_tests_status: nil)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, head_tests_status: :passed)
    assert_empty Solution::SearchCommunitySolutions.(exercise, head_tests_status: :failed)
    assert_equal [solution_3], Solution::SearchCommunitySolutions.(exercise, head_tests_status: :errored)
    assert_equal [solution_3], Solution::SearchCommunitySolutions.(exercise, head_tests_status: "errored")
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchCommunitySolutions.(exercise, head_tests_status: %i[passed errored])
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchCommunitySolutions.(exercise, head_tests_status: "passed errored")
  end

  test "filter: sync_status" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, git_important_files_hash: exercise.git_important_files_hash,
      num_stars: 11, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise:, git_important_files_hash: exercise.git_important_files_hash,
      num_stars: 22, published_at: Time.current, status: :published
    solution_3 = create :concept_solution, exercise:, git_important_files_hash: 'different_hash', num_stars: 33,
      published_at: Time.current, status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_3, solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, sync_status: nil)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, sync_status: :up_to_date)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, sync_status: "up_to_date")
    assert_equal [solution_3], Solution::SearchCommunitySolutions.(exercise, sync_status: :out_of_date)
    assert_equal [solution_3], Solution::SearchCommunitySolutions.(exercise, sync_status: "out_of_date")
  end

  test "pagination" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 1)
    assert_equal [solution_1], Solution::SearchCommunitySolutions.(exercise, page: 2, per: 1)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions.(exercise, page: 1, per: 2)
    assert_empty Solution::SearchCommunitySolutions.(exercise, page: 2, per: 2)
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

  test "sort newest first" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    new_solution = create :concept_solution, exercise:, published_at: Time.current - 1.week, status: :published
    old_solution = create :concept_solution, exercise:, published_at: Time.current - 2.weeks, status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [new_solution, old_solution], Solution::SearchCommunitySolutions.(exercise, order: "newest")
  end

  test "sort most starred first" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    least_starred = create :concept_solution, exercise:, num_stars: 2, published_at: Time.current - 1.week,
      status: :published
    most_starred = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current - 2.weeks,
      status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [most_starred, least_starred], Solution::SearchCommunitySolutions.(exercise, order: "most_starred")
  end

  test "sort most starred first by default" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    least_starred = create :concept_solution, exercise:, num_stars: 2, published_at: Time.current - 1.week,
      status: :published
    most_starred = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current - 2.weeks,
      status: :published

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchCommunitySolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [most_starred, least_starred], Solution::SearchCommunitySolutions.(exercise, order: nil)
  end

  test "fallback is called" do
    exercise = create :concept_exercise
    Solution::SearchCommunitySolutions::Fallback.expects(:call).with(exercise, 2, 15, :newest, "foobar", :passed, :failed, :up_to_date)
    OpenSearch::Client.expects(:new).raises

    Solution::SearchCommunitySolutions.(exercise, page: 2, per: 15, order: "newest", criteria: "foobar", tests_status: :passed, head_tests_status: :failed, sync_status: :up_to_date) # rubocop:disable Layout:LineLength
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
    Solution::SearchCommunitySolutions::Fallback.expects(:call).with(exercise, 2, 15, :newest, "foobar", :passed,
      :passed, :up_to_date)

    Solution::SearchCommunitySolutions.(exercise, page: 2, per: 15, order: "newest", criteria: "foobar", tests_status: :passed,
      head_tests_status: :passed, sync_status: :up_to_date)
  end

  test "fallback: no options returns all published" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 10, nil, "", nil, nil, nil)
  end

  test "fallback: criteria: search for user handle" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    user_1 = create :user, handle: 'amy'
    user_2 = create :user, handle: 'chris'
    solution_1 = create :concept_solution, exercise:, user: user_1, num_stars: 11, published_at: Time.current,
      status: :published
    solution_2 = create :concept_solution, exercise:, user: user_2, num_stars: 22, published_at: Time.current,
      status: :published

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, nil, nil, nil, nil)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, nil, nil)
    assert_equal [solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "amy", nil, nil, nil)
    assert_equal [solution_2], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "ris", nil, nil, nil)
  end

  test "fallback: filter: tests_status" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published
    submission_1 = create :submission, solution: solution_1, tests_status: :passed
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published
    submission_2 = create :submission, solution: solution_2, tests_status: :passed
    solution_3 = create :concept_solution, exercise:, num_stars: 33, published_at: Time.current, status: :published
    submission_3 = create :submission, solution: solution_3, tests_status: :failed
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3, submission: submission_3))

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, nil, nil)
    assert_equal [solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", :passed, nil, nil)
    assert_equal [solution_3], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", :failed, nil, nil)
    assert_empty Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", :errored, nil, nil)
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", %i[passed failed], nil, nil)
  end

  test "fallback: filter: head_tests_status" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published,
      published_iteration_head_tests_status: :passed
    submission_1 = create :submission, solution: solution_1, tests_status: :passed
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published,
      published_iteration_head_tests_status: :passed
    submission_2 = create :submission, solution: solution_2, tests_status: :passed
    solution_3 = create :concept_solution, exercise:, num_stars: 33, published_at: Time.current, status: :published,
      published_iteration_head_tests_status: :errored
    submission_3 = create :submission, solution: solution_3, tests_status: :failed
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3, submission: submission_3))

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, nil, nil)
    assert_equal [solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, :passed, nil)
    assert_empty Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, :failed, nil)
    assert_equal [solution_3], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, :errored, nil)
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, %i[passed errored], nil)
  end

  test "fallback: filter: sync_status" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, git_important_files_hash: exercise.git_important_files_hash,
      num_stars: 11, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise:, git_important_files_hash: exercise.git_important_files_hash,
      num_stars: 22, published_at: Time.current, status: :published
    solution_3 = create :concept_solution, exercise:, git_important_files_hash: 'different_hash', num_stars: 33,
      published_at: Time.current, status: :published

    # Unpublished
    create(:concept_solution, exercise:)

    # A different exercise
    create :concept_solution

    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, nil, nil)
    assert_equal [solution_2, solution_1],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, nil, :up_to_date)
    assert_equal [solution_3], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, nil, :out_of_date)
  end

  test "fallback: pagination" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution_1 = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current, status: :published
    solution_2 = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current, status: :published

    assert_equal [solution_2], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 1, nil, "", nil, nil, nil)
    assert_equal [solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 1, nil, "", nil, nil, nil)
    assert_equal [solution_2, solution_1], Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 2, nil, "", nil, nil, nil)
    assert_empty Solution::SearchCommunitySolutions::Fallback.(exercise, 2, 2, nil, "", nil, nil, nil)
  end

  test "fallback: sort newest first" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    new_solution = create :concept_solution, exercise:, published_at: Time.current - 1.week, status: :published
    old_solution = create :concept_solution, exercise:, published_at: Time.current - 2.weeks, status: :published

    assert_equal [new_solution, old_solution],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, :newest, "", nil, nil, nil)
  end

  test "fallback: sort most starred first" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    least_starred = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current - 1.week,
      status: :published
    most_starred = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current - 2.weeks,
      status: :published

    assert_equal [most_starred, least_starred],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, :most_starred, "", nil, nil, nil)
  end

  test "fallback: sort most starred first by default" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    least_starred = create :concept_solution, exercise:, num_stars: 11, published_at: Time.current - 1.week,
      status: :published
    most_starred = create :concept_solution, exercise:, num_stars: 22, published_at: Time.current - 2.weeks,
      status: :published

    assert_equal [most_starred, least_starred],
      Solution::SearchCommunitySolutions::Fallback.(exercise, 1, 15, nil, "", nil, nil, nil)
  end
end

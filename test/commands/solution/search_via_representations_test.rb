require "test_helper"

class Solution::SearchViaRepresentationsTest < ActiveSupport::TestCase
  test "returns one solution for each exercise representation" do
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create(:iteration, solution: solution_2, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create(:iteration, solution: solution_3, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    # Verify that solution_2, which has the same representation as solution_1, is _not_ included
    assert_equal [solution_1, solution_3], Solution::SearchViaRepresentations.(exercise)
  end

  test "only returns solutions of specified exercise" do
    user = create :user
    ruby = create :track, title: "Ruby"

    exercise = create :concept_exercise, track: ruby
    exercise_representation = create(:exercise_representation, exercise:)
    solution = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation
    submission = create :submission, solution:, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation.ast
    create(:iteration, solution:, submission:)

    other_exercise = create :practice_exercise, track: ruby
    other_exercise_representation = create(:exercise_representation, exercise: other_exercise)
    other_solution = create :concept_solution, exercise: other_exercise, published_at: 2.days.ago, user:,
      git_important_files_hash: other_exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: other_exercise_representation
    other_submission = create :submission, solution: other_solution, tests_status: :failed
    create :submission_representation, submission: other_submission, ast: other_exercise_representation.ast
    create :iteration, solution: other_solution, submission: other_submission

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation)
      Exercise::Representation::Recache.(other_exercise_representation)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution], Solution::SearchViaRepresentations.(exercise)
    assert_equal [other_solution], Solution::SearchViaRepresentations.(other_exercise)
  end

  test "filter: criteria" do
    exercise = create :practice_exercise

    data = %i[my your another].each_with_object({}) do |word, d|
      solution = create :concept_solution, exercise:, published_at: 2.days.ago,
        git_important_files_hash: exercise.git_important_files_hash,
        published_iteration_head_tests_status: :passed
      submission = create :submission, solution:, tests_status: :passed
      create :submission_file, submission:, filename: "main.rb", content: "def #{word}_main; end"
      create(:iteration, solution:, submission:)

      exercise_representation = create(:exercise_representation, exercise:, source_submission: submission)
      solution.update(published_exercise_representation: exercise_representation)

      d[word] = { representation: exercise_representation, solution: }
    end

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(data[:my][:representation])
      Exercise::Representation::Recache.(data[:your][:representation])
      Exercise::Representation::Recache.(data[:another][:representation])
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [data[:my][:solution]], Solution::SearchViaRepresentations.(exercise, criteria: 'my_main')
    assert_equal [data[:your][:solution]], Solution::SearchViaRepresentations.(exercise, criteria: 'your_main')
    assert_equal [data[:another][:solution]], Solution::SearchViaRepresentations.(exercise, criteria: 'another_main')
    assert_equal data.values.map { |d| d[:solution] }, Solution::SearchViaRepresentations.(exercise, criteria: 'main')
  end

  test "pagination" do
    user = create :user, handle: 'john'
    other_user = create :user, handle: 'jane'
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
    create(:iteration, solution: solution_2, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_1], Solution::SearchViaRepresentations.(exercise, page: 1, per: 1)
    assert_equal [solution_2], Solution::SearchViaRepresentations.(exercise, page: 2, per: 1)
    assert_equal [solution_1, solution_2], Solution::SearchViaRepresentations.(exercise, page: 0, per: 0)
    assert_equal [solution_1, solution_2], Solution::SearchViaRepresentations.(exercise, page: 'foo', per: 'bar')
  end

  test "sort: most popular" do
    user = create :user, handle: 'john'
    other_user = create :user, handle: 'jane'
    another_user = create :user, handle: 'june'
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
    create(:iteration, solution: solution_2, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago, user: another_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def another_main; end"
    create(:iteration, solution: solution_3, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_1, solution_3], Solution::SearchViaRepresentations.(exercise, order: :most_popular)
    assert_equal [solution_1, solution_3], Solution::SearchViaRepresentations.(exercise)
  end

  test "sort: oldest" do
    user = create :user, handle: 'john'
    other_user = create :user, handle: 'jane'
    another_user = create :user, handle: 'june'
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)
    exercise_representation_3 = create(:exercise_representation, exercise:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
    create(:iteration, solution: solution_2, submission:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
    create(:iteration, solution: solution_1, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago, user: another_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_3
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_3.ast
    create :submission_file, submission:, filename: "main.rb", content: "def another_main; end"
    create(:iteration, solution: solution_3, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
      Exercise::Representation::Recache.(exercise_representation_3)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1, solution_3], Solution::SearchViaRepresentations.(exercise, order: :oldest)
  end

  test "sort: newest" do
    user = create :user, handle: 'john'
    other_user = create :user, handle: 'jane'
    another_user = create :user, handle: 'june'
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)
    exercise_representation_3 = create(:exercise_representation, exercise:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
    create(:iteration, solution: solution_2, submission:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
    create(:iteration, solution: solution_1, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago, user: another_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_3
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_3.ast
    create :submission_file, submission:, filename: "main.rb", content: "def another_main; end"
    create(:iteration, solution: solution_3, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
      Exercise::Representation::Recache.(exercise_representation_3)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_3, solution_1, solution_2], Solution::SearchViaRepresentations.(exercise, order: :newest)
  end

  test "sort: fewest_loc" do
    user = create :user, handle: 'john'
    other_user = create :user, handle: 'jane'
    another_user = create :user, handle: 'june'
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)
    exercise_representation_3 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1,
      num_loc: 20
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2,
      num_loc: 10
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
    create(:iteration, solution: solution_2, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago, user: another_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_3,
      num_loc: 50
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_3.ast
    create :submission_file, submission:, filename: "main.rb", content: "def another_main; end"
    create(:iteration, solution: solution_3, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
      Exercise::Representation::Recache.(exercise_representation_3)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1, solution_3], Solution::SearchViaRepresentations.(exercise, order: :fewest_loc)
  end

  test "sort: highest reputation" do
    exercise = create :practice_exercise
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solutions = [
      exercise_representation_1,
      exercise_representation_1,
      exercise_representation_1,
      exercise_representation_2
    ].map do |representation|
      create_solution(exercise:, representation:)
    end

    # We want the middle one to be the prestigious one that's returned
    create :user_reputation_period, user: solutions[0].user, reputation: 20,
      period: :forever, category: :any, about: :track, track_id: exercise.track_id
    create :user_reputation_period, user: solutions[1].user, reputation: 50,
      period: :forever, category: :any, about: :track, track_id: exercise.track_id
    create :user_reputation_period, user: solutions[2].user, reputation: 15,
      period: :forever, category: :any, about: :track, track_id: exercise.track_id

    create :user_reputation_period, user: solutions[3].user, reputation: 30,
      period: :forever, category: :any, about: :track, track_id: exercise.track_id

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
    end

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchViaRepresentations::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solutions[1], solutions[3]], Solution::SearchViaRepresentations.(exercise, order: :highest_reputation)
  end

  test "fallback is called" do
    exercise = create :practice_exercise
    Solution::SearchViaRepresentations::Fallback.expects(:call).with(exercise, 2, 15, :oldest_first, "foobar")
    OpenSearch::Client.expects(:new).raises

    Solution::SearchViaRepresentations.(exercise, page: 2, per: 15, criteria: "foobar", order: "oldest_first")
  end

  test "fallback is called when elasticsearch times out" do
    # Simulate a timeout
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Solution::SearchViaRepresentations.any_instance.stubs(:search_query).returns({
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

    exercise = create :practice_exercise
    Solution::SearchViaRepresentations::Fallback.expects(:call).with(exercise, 2, 15, :oldest_first, "foobar")

    Solution::SearchViaRepresentations.(exercise, page: 2, per: 15, criteria: "foobar", order: "oldest_first")
  end

  test "fallback: returns one solution for each exercise representation" do
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create(:iteration, solution: solution_2, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create(:iteration, solution: solution_3, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
    end

    wait_for_opensearch_to_be_synced

    # Verify that solution_2, which has the same representation as solution_1, is _not_ included
    assert_equal [solution_1, solution_3], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 24, :most_popular, nil)
  end

  test "fallback: only returns solutions of specified exercise" do
    user = create :user
    ruby = create :track, title: "Ruby"

    exercise = create :concept_exercise, track: ruby
    exercise_representation = create(:exercise_representation, exercise:)
    solution = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation
    submission = create :submission, solution:, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation.ast
    create(:iteration, solution:, submission:)

    other_exercise = create :practice_exercise, track: ruby
    other_exercise_representation = create(:exercise_representation, exercise: other_exercise)
    other_solution = create :concept_solution, exercise: other_exercise, published_at: 2.days.ago, user:,
      git_important_files_hash: other_exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: other_exercise_representation
    other_submission = create :submission, solution: other_solution, tests_status: :failed
    create :submission_representation, submission: other_submission, ast: other_exercise_representation.ast
    create :iteration, solution: other_solution, submission: other_submission

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation)
      Exercise::Representation::Recache.(other_exercise_representation)
    end

    assert_equal [solution], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 24, :most_popular, nil)
    assert_equal [other_solution], Solution::SearchViaRepresentations::Fallback.(other_exercise, 1, 24, :most_popular, nil)
  end

  test "fallback: pagination" do
    exercise = create :practice_exercise
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
    create(:iteration, solution: solution_2, submission:)

    perform_enqueued_jobs do
      Exercise::Representation::Recache.(exercise_representation_1)
      Exercise::Representation::Recache.(exercise_representation_2)
    end

    assert_equal [solution_1], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 1, :most_popular, nil)
    assert_equal [solution_2], Solution::SearchViaRepresentations::Fallback.(exercise, 2, 1, :most_popular, nil)
  end

  test "fallback: sort: most popular" do
    exercise = create :practice_exercise
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create(:submission_file, submission:)
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create(:submission_file, submission:)
    create(:iteration, solution: solution_2, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create(:submission_file, submission:)
    create(:iteration, solution: solution_3, submission:)

    exercise_representation_1.update(num_published_solutions: 1)
    exercise_representation_2.update(num_published_solutions: 2)

    assert_equal [solution_2, solution_1], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 24, :most_popular, nil)
  end

  test "fallback: sort: oldest" do
    exercise = create :practice_exercise
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solutions = [
      exercise_representation_1,
      exercise_representation_2,
      exercise_representation_2
    ].map do |representation|
      create_solution(exercise:, representation:)
    end

    assert_equal [solutions[0], solutions[1]], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 24, :oldest, nil)
  end

  test "fallback: sort: newest" do
    exercise = create :practice_exercise
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solutions = [
      exercise_representation_1,
      exercise_representation_2,
      exercise_representation_2
    ].map do |representation|
      create_solution(exercise:, representation:)
    end

    assert_equal [solutions[1], solutions[0]], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 24, :newest, nil)
  end

  test "fallback: sort: num_loc" do
    exercise = create :practice_exercise
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solutions = [
      [exercise_representation_1, 20],
      [exercise_representation_2, 50],
      [exercise_representation_2, 10]
    ].map do |(representation, num_loc)|
      create_solution(exercise:, representation:, num_loc:)
    end

    assert_equal [solutions[1], solutions[0]], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 24, :fewest_loc, nil)
  end

  test "fallback: sort: highest_reputation" do
    user = create :user, handle: 'john', reputation: 15
    other_user = create :user, handle: 'jane', reputation: 50
    another_user = create :user, handle: 'june', reputation: 30
    ruby = create :track, title: "Ruby"

    exercise = create :practice_exercise, track: ruby
    exercise_representation_1 = create(:exercise_representation, exercise:)
    exercise_representation_2 = create(:exercise_representation, exercise:)

    solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user:,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_1,
      num_loc: 20
    submission = create :submission, solution: solution_1, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_1.ast
    create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
    create(:iteration, solution: solution_1, submission:)

    solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2,
      num_loc: 50
    submission = create :submission, solution: solution_2, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
    create(:iteration, solution: solution_2, submission:)

    solution_3 = create :concept_solution, exercise:, published_at: 2.days.ago, user: another_user,
      git_important_files_hash: exercise.git_important_files_hash,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: exercise_representation_2,
      num_loc: 10
    submission = create :submission, solution: solution_3, tests_status: :passed
    create :submission_representation, submission:, ast: exercise_representation_2.ast
    create :submission_file, submission:, filename: "main.rb", content: "def another_main; end"
    create(:iteration, solution: solution_3, submission:)

    assert_equal [solution_2, solution_1], Solution::SearchViaRepresentations::Fallback.(exercise, 1, 24, :highest_reputation, nil)
  end

  private
  def create_solution(exercise:, representation: nil, num_loc: nil)
    solution = create(:concept_solution, :published, exercise:,
      published_iteration_head_tests_status: :passed,
      published_exercise_representation: representation,
      num_loc:)
    submission = create :submission, solution:, tests_status: :passed
    create :submission_representation, submission:, ast: representation.ast
    create(:submission_file, submission:)
    create(:iteration, solution:, submission:)

    solution
  end
end

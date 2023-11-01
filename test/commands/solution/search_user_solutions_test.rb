require "test_helper"

class Solution::SearchUserSolutionsTest < ActiveSupport::TestCase
  test "no options returns everything" do
    user = create :user
    solution_1 = create :concept_solution, user:, num_stars: 1
    solution_2 = create :practice_solution, user:, num_stars: 2

    # Someone else's solution
    create :concept_solution

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user)
  end

  test "filter: criteria" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby"
    js_bob = create :concept_exercise, title: "Bob", track: javascript
    ruby_food = create :concept_exercise, title: "Food Chain", track: ruby
    ruby_bob = create :concept_exercise, title: "Bob", track: ruby

    js_bob_solution = create :practice_solution, user:, exercise: js_bob, published_at: 3.weeks.ago
    ruby_food_solution = create :concept_solution, user:, exercise: ruby_food, num_stars: 1
    ruby_bob_solution = create :concept_solution, user:, exercise: ruby_bob, num_stars: 2

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::SearchUserSolutions.(user)
    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::SearchUserSolutions.(user, criteria: " ")
    assert_equal [ruby_bob_solution, ruby_food_solution], Solution::SearchUserSolutions.(user, criteria: "ru")
    assert_equal [ruby_bob_solution, js_bob_solution], Solution::SearchUserSolutions.(user, criteria: "bo")
    assert_equal [ruby_bob_solution], Solution::SearchUserSolutions.(user, criteria: "ru bo")
    assert_equal [ruby_food_solution], Solution::SearchUserSolutions.(user, criteria: "r ch fo")
  end

  test "filter: track_slug" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'
    common_lisp = create :track, title: "Common Lisp", slug: 'common-lisp'
    ruby_exercise = create :practice_exercise, track: ruby
    js_exercise = create :practice_exercise, track: javascript
    elixir_exercise = create :practice_exercise, track: elixir
    common_lisp_exercise = create :practice_exercise, track: common_lisp

    ruby_solution = create :practice_solution, user:, exercise: ruby_exercise, published_at: 3.weeks.ago
    js_solution = create :practice_solution, user:, exercise: js_exercise, num_stars: 1
    elixir_solution = create :practice_solution, user:, exercise: elixir_exercise, num_stars: 2
    common_lisp_solution = create :practice_solution, user:, exercise: common_lisp_exercise, num_stars: 3

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [common_lisp_solution, elixir_solution, js_solution, ruby_solution], Solution::SearchUserSolutions.(user)
    assert_equal [js_solution, ruby_solution], Solution::SearchUserSolutions.(user, track_slug: %i[ruby javascript])
    assert_equal [ruby_solution], Solution::SearchUserSolutions.(user, track_slug: "ruby")
    assert_equal [common_lisp_solution], Solution::SearchUserSolutions.(user, track_slug: "common-lisp")
  end

  test "filter: status" do
    user = create :user
    published = create :practice_solution, user:, status: :published, published_at: 3.weeks.ago
    completed = create :practice_solution, user:, status: :completed, num_stars: 1
    iterated = create :concept_solution, user:, status: :iterated, num_stars: 2

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [iterated, completed, published], Solution::SearchUserSolutions.(user, status: nil)
    assert_equal [iterated], Solution::SearchUserSolutions.(user, status: :iterated)
    assert_equal [iterated], Solution::SearchUserSolutions.(user, status: 'iterated')
    assert_equal [completed, published], Solution::SearchUserSolutions.(user, status: %i[completed published])
    assert_equal [completed, published], Solution::SearchUserSolutions.(user, status: %w[completed published])
    assert_equal [published], Solution::SearchUserSolutions.(user, status: :published)
    assert_equal [published], Solution::SearchUserSolutions.(user, status: 'published')
  end

  test "filter: mentoring_status" do
    user = create :user
    finished = create :concept_solution, user:, mentoring_status: :finished, num_stars: 3
    in_progress = create :concept_solution, user:, mentoring_status: :in_progress, num_stars: 5
    requested = create :concept_solution, user:, mentoring_status: :requested, num_stars: 7
    none = create :concept_solution, user:, mentoring_status: :none, num_stars: 9

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [none, requested, in_progress, finished], Solution::SearchUserSolutions.(user, mentoring_status: nil)

    assert_equal [none], Solution::SearchUserSolutions.(user, mentoring_status: :none)
    assert_equal [none], Solution::SearchUserSolutions.(user, mentoring_status: 'none')

    assert_equal [requested], Solution::SearchUserSolutions.(user, mentoring_status: :requested)
    assert_equal [requested], Solution::SearchUserSolutions.(user, mentoring_status: 'requested')

    assert_equal [in_progress], Solution::SearchUserSolutions.(user, mentoring_status: :in_progress)
    assert_equal [in_progress], Solution::SearchUserSolutions.(user, mentoring_status: 'in_progress')

    assert_equal [finished], Solution::SearchUserSolutions.(user, mentoring_status: :finished)
    assert_equal [finished], Solution::SearchUserSolutions.(user, mentoring_status: 'finished')

    assert_equal [none, finished], Solution::SearchUserSolutions.(user, mentoring_status: [:none, 'finished'])
  end

  test "filter: tests_status" do
    user = create :user
    solution_1 = create :concept_solution, user:, published_at: Time.current, num_stars: 11
    solution_2 = create :concept_solution, user:, published_at: Time.current, num_stars: 22
    solution_3 = create :concept_solution, user:, published_at: Time.current, num_stars: 33
    submission_1 = create :submission, solution: solution_1
    submission_2 = create :submission, solution: solution_2
    submission_3 = create :submission, solution: solution_3
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3, submission: submission_3))

    # We have to set these via the update_column so they don't get
    # overriden by all the processes that kick off
    perform_enqueued_jobs_until_empty

    submission_1.reload.update_column(:tests_status, :passed)
    submission_2.reload.update_column(:tests_status, :passed)
    submission_3.reload.update_column(:tests_status, :failed)
    Solution::SyncToSearchIndex.(solution_1)
    Solution::SyncToSearchIndex.(solution_2)
    Solution::SyncToSearchIndex.(solution_3)
    wait_for_opensearch_to_be_synced

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    # A different user
    create :concept_solution

    assert_equal [solution_3, solution_2, solution_1], Solution::SearchUserSolutions.(user, tests_status: nil)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, tests_status: :passed)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, tests_status: "passed")
    assert_equal [solution_3], Solution::SearchUserSolutions.(user, tests_status: :failed)
    assert_empty Solution::SearchUserSolutions.(user, tests_status: :errored)
    assert_equal [solution_3, solution_2, solution_1], Solution::SearchUserSolutions.(user, tests_status: %i[passed failed])
    assert_equal [solution_3, solution_2, solution_1], Solution::SearchUserSolutions.(user, tests_status: "passed failed")
  end

  test "filter: head_tests_status" do
    Solution::QueueHeadTestRun.stubs(:defer)

    user = create :user
    solution_1 = create :concept_solution, user:, published_iteration_head_tests_status: :passed, published_at: Time.current,
      num_stars: 11
    solution_2 = create :concept_solution, user:, published_iteration_head_tests_status: :passed, published_at: Time.current,
      num_stars: 22
    solution_3 = create :concept_solution, user:, published_iteration_head_tests_status: :errored, published_at: Time.current,
      num_stars: 33
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1,
      submission: create(:submission, solution: solution_1)))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2,
      submission: create(:submission, solution: solution_2)))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3,
      submission: create(:submission, solution: solution_3)))

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    # A different user
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_3, solution_2, solution_1], Solution::SearchUserSolutions.(user, head_tests_status: nil)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, head_tests_status: :passed)
    assert_empty Solution::SearchUserSolutions.(user, head_tests_status: :failed)
    assert_equal [solution_3], Solution::SearchUserSolutions.(user, head_tests_status: :errored)
    assert_equal [solution_3], Solution::SearchUserSolutions.(user, head_tests_status: "errored")
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchUserSolutions.(user, head_tests_status: %i[passed errored])
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchUserSolutions.(user, head_tests_status: "passed errored")
  end

  test "filter: sync_status" do
    user = create :user
    exercise_1 = create :concept_exercise
    exercise_2 = create :concept_exercise
    exercise_3 = create :concept_exercise
    solution_1 = create :concept_solution, user:, exercise: exercise_1,
      git_important_files_hash: exercise_1.git_important_files_hash, num_stars: 11
    solution_2 = create :concept_solution, user:, exercise: exercise_2,
      git_important_files_hash: exercise_2.git_important_files_hash, num_stars: 22
    solution_3 = create :concept_solution, user:, exercise: exercise_3,
      git_important_files_hash: 'different_hash', num_stars: 33

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    # A different user
    create :concept_solution

    wait_for_opensearch_to_be_synced

    assert_equal [solution_3, solution_2, solution_1], Solution::SearchUserSolutions.(user, sync_status: nil)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, sync_status: :up_to_date)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, sync_status: "up_to_date")
    assert_equal [solution_3], Solution::SearchUserSolutions.(user, sync_status: :out_of_date)
    assert_equal [solution_3], Solution::SearchUserSolutions.(user, sync_status: "out_of_date")
  end

  test "pagination" do
    user = create :user
    solution_1 = create :concept_solution, user:, num_stars: 1
    solution_2 = create :concept_solution, user:, num_stars: 2

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2], Solution::SearchUserSolutions.(user, page: 1, per: 1)
    assert_equal [solution_1], Solution::SearchUserSolutions.(user, page: 2, per: 1)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, page: 1, per: 2)
    assert_empty Solution::SearchUserSolutions.(user, page: 2, per: 2)
  end

  test "pagination with invalid values" do
    user = create :user
    solution_1 = create :concept_solution, user:, num_stars: 1
    solution_2 = create :concept_solution, user:, num_stars: 2

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, page: 0, per: 0)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions.(user, page: 'foo', per: 'bar')
  end

  test "sort most starred first" do
    user = create :user
    most_starred_solution = create :concept_solution, user:, num_stars: 10
    least_starred_solution = create :concept_solution, user:, num_stars: 4

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [most_starred_solution, least_starred_solution], Solution::SearchUserSolutions.(user, order: :most_starred)
  end

  test "sort oldest first" do
    user = create :user
    old_solution = create :concept_solution, user:, num_stars: 1
    new_solution = create :concept_solution, user:, num_stars: 2

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [old_solution, new_solution], Solution::SearchUserSolutions.(user, order: :oldest_first)
  end

  test "sort newest first by default" do
    user = create :user
    old_solution = create :concept_solution, user:, num_stars: 1
    new_solution = create :concept_solution, user:, num_stars: 2

    # Sanity check: ensure that the results are not returned using the fallback
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [new_solution, old_solution], Solution::SearchUserSolutions.(user)
  end

  test "fallback is called" do
    user = create :user
    Solution::SearchUserSolutions::Fallback.expects(:call).with(user, 2, 15, "csharp", "published", "none", "foobar", :oldest_first,
      :up_to_date, "passed", "failed")
    OpenSearch::Client.expects(:new).raises

    Solution::SearchUserSolutions.(user, page: 2, per: 15, track_slug: "csharp", status: "published", mentoring_status: "none",
      criteria: "foobar", order: "oldest_first", sync_status: "up_to_date", tests_status: "passed", head_tests_status: "failed")
  end

  test "fallback is called when elasticsearch times out" do
    # Simulate a timeout
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Solution::SearchUserSolutions.any_instance.stubs(:search_query).returns({
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

    user = create :user
    Solution::SearchUserSolutions::Fallback.expects(:call).with(user, 2, 15, "csharp", "published", "none", "foobar", :oldest_first,
      :up_to_date, "passed", "failed")

    Solution::SearchUserSolutions.(user, page: 2, per: 15, track_slug: "csharp", status: "published", mentoring_status: "none",
      criteria: "foobar", order: "oldest_first", sync_status: 'up_to_date', tests_status: "passed", head_tests_status: "failed")
  end

  test "fallback: no options returns everything" do
    user = create :user
    solution_1 = create :concept_solution, user:, num_stars: 1
    solution_2 = create :practice_solution, user:, num_stars: 2

    # Someone else's solution
    create :concept_solution

    assert_equal [solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
  end

  test "fallback: filter: criteria" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby"
    js_bob = create :concept_exercise, title: "Bob", track: javascript
    ruby_food = create :concept_exercise, title: "Food Chain", track: ruby
    ruby_bob = create :concept_exercise, title: "Bob", track: ruby

    js_bob_solution = create :practice_solution, user:, exercise: js_bob, published_at: 3.weeks.ago
    ruby_food_solution = create :concept_solution, user:, exercise: ruby_food, num_stars: 1
    ruby_bob_solution = create :concept_solution, user:, exercise: ruby_bob, num_stars: 2

    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, " ", nil, nil, nil, nil) # rubocop:disable Layout:LineLength
    assert_equal [ruby_bob_solution, ruby_food_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, "ru", nil, nil, nil, nil)
    assert_equal [ruby_bob_solution, js_bob_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, "bo", nil, nil, nil, nil)
    assert_equal [ruby_bob_solution].map(&:track),
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, "ru bo", nil, nil, nil, nil).map(&:track)
    assert_equal [ruby_food_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, "r ch fo", nil, nil, nil, nil)
  end

  test "fallback: filter: track_slug" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'
    ruby_exercise = create :practice_exercise, track: ruby
    js_exercise = create :practice_exercise, track: javascript
    elixir_exercise = create :practice_exercise, track: elixir

    ruby_solution = create :practice_solution, user:, exercise: ruby_exercise, published_at: 3.weeks.ago
    js_solution = create :practice_solution, user:, exercise: js_exercise, num_stars: 1
    elixir_solution = create :practice_solution, user:, exercise: elixir_exercise, num_stars: 2

    assert_equal [elixir_solution, js_solution, ruby_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [js_solution, ruby_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, %i[ruby javascript], nil, nil, nil, nil, nil, nil, nil)
    assert_equal [ruby_solution], Solution::SearchUserSolutions::Fallback.(user, 1, 15, "ruby", nil, nil, nil, nil, nil, nil, nil)
  end

  test "fallback: filter: status" do
    user = create :user
    published = create :practice_solution, user:, status: :published, num_stars: 3
    completed = create :practice_solution, user:, status: :completed, num_stars: 5
    iterated = create :concept_solution, user:, status: :iterated, num_stars: 7

    assert_equal [iterated, completed, published],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [iterated], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, :iterated, nil, nil, nil, nil, nil, nil)
    assert_equal [iterated], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, 'iterated', nil, nil, nil, nil, nil, nil)
    assert_equal [completed, published],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, %i[completed published], nil, nil, nil, nil, nil, nil)
    assert_equal [completed, published],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, %w[completed published], nil, nil, nil, nil, nil, nil)
    assert_equal [published], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, :published, nil, nil, nil, nil, nil, nil)
    assert_equal [published], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, 'published', nil, nil, nil, nil, nil, nil)
  end

  test "fallback: filter: mentoring_status" do
    user = create :user
    finished = create :concept_solution, user:, mentoring_status: :finished, num_stars: 1
    in_progress = create :concept_solution, user:, mentoring_status: :in_progress, num_stars: 3
    requested = create :concept_solution, user:, mentoring_status: :requested, num_stars: 7
    none = create :concept_solution, user:, mentoring_status: :none, num_stars: 9

    assert_equal [none, requested, in_progress, finished],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)

    assert_equal [none], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :none, nil, nil, nil, nil, nil)
    assert_equal [none], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, 'none', nil, nil, nil, nil, nil)

    assert_equal [requested], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :requested, nil, nil, nil, nil, nil)
    assert_equal [requested], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, 'requested', nil, nil, nil, nil, nil)

    assert_equal [in_progress], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :in_progress, nil, nil, nil, nil, nil)
    assert_equal [in_progress], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, 'in_progress', nil, nil, nil, nil, nil)

    assert_equal [finished], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :finished, nil, nil, nil, nil, nil)
    assert_equal [finished], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, 'finished', nil, nil, nil, nil, nil)

    assert_equal [none, finished],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, [:none, 'finished'], nil, nil, nil, nil, nil)
  end

  test "fallback: filter: tests_status" do
    user = create :user
    solution_1 = create :concept_solution, user:, published_at: Time.current, num_stars: 11
    solution_2 = create :concept_solution, user:, published_at: Time.current, num_stars: 22
    solution_3 = create :concept_solution, user:, published_at: Time.current, num_stars: 33
    submission_1 = create :submission, solution: solution_1, tests_status: :passed
    submission_2 = create :submission, solution: solution_2, tests_status: :passed
    submission_3 = create :submission, solution: solution_3, tests_status: :failed
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3, submission: submission_3))

    # A different user
    create :concept_solution

    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :none, nil, nil, nil, :passed, nil)
    assert_equal [solution_3], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :none, nil, nil, nil, :failed, nil)
    assert_empty Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :none, nil, nil, nil, :errored, nil)
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, :none, nil, nil, nil, %i[passed failed], nil)
  end

  test "fallback: filter: head_tests_status" do
    user = create :user
    solution_1 = create :concept_solution, user:, published_iteration_head_tests_status: :passed, published_at: Time.current,
      num_stars: 11
    solution_2 = create :concept_solution, user:, published_iteration_head_tests_status: :passed, published_at: Time.current,
      num_stars: 22
    solution_3 = create :concept_solution, user:, published_iteration_head_tests_status: :errored, published_at: Time.current,
      num_stars: 33
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1,
      submission: create(:submission, solution: solution_1)))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2,
      submission: create(:submission, solution: solution_2)))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3,
      submission: create(:submission, solution: solution_3)))

    # A different user
    create :concept_solution

    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, :passed)
    assert_empty Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, :failed)
    assert_equal [solution_3], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, :errored)
    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, %i[passed errored])
  end

  test "fallback: filter: sync_status" do
    user = create :user
    exercise_1 = create :concept_exercise
    exercise_2 = create :concept_exercise
    exercise_3 = create :concept_exercise
    solution_1 = create :concept_solution, user:, exercise: exercise_1,
      git_important_files_hash: exercise_1.git_important_files_hash, published_at: Time.current, num_stars: 11
    solution_2 = create :concept_solution, user:, exercise: exercise_2,
      git_important_files_hash: exercise_2.git_important_files_hash, published_at: Time.current, num_stars: 22
    solution_3 = create :concept_solution, user:, exercise: exercise_3, git_important_files_hash: 'different_hash',
      published_at: Time.current, num_stars: 33
    solution_1.update!(published_iteration: create(:iteration, solution: solution_1,
      submission: create(:submission, solution: solution_1)))
    solution_2.update!(published_iteration: create(:iteration, solution: solution_2,
      submission: create(:submission, solution: solution_2)))
    solution_3.update!(published_iteration: create(:iteration, solution: solution_3,
      submission: create(:submission, solution: solution_3)))

    # A different user
    create :concept_solution

    assert_equal [solution_3, solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [solution_2, solution_1],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, :up_to_date, nil, nil)
    assert_equal [solution_3], Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, :out_of_date, nil, nil)
  end

  test "fallback: pagination" do
    user = create :user
    solution_1 = create :concept_solution, user:, num_stars: 1
    solution_2 = create :concept_solution, user:, num_stars: 2

    assert_equal [solution_2], Solution::SearchUserSolutions::Fallback.(user, 1, 1, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [solution_1], Solution::SearchUserSolutions::Fallback.(user, 2, 1, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_equal [solution_2, solution_1], Solution::SearchUserSolutions::Fallback.(user, 1, 2, nil, nil, nil, nil, nil, nil, nil, nil)
    assert_empty Solution::SearchUserSolutions::Fallback.(user, 2, 2, nil, nil, nil, nil, nil, nil, nil, nil)
  end

  test "fallback: sort oldest first" do
    user = create :user
    old_solution = create :concept_solution, user:, num_stars: 1
    new_solution = create :concept_solution, user:, num_stars: 2

    assert_equal [old_solution, new_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, :oldest_first, nil, nil, nil)
  end

  test "fallback: sort newest first" do
    user = create :user
    old_solution = create :concept_solution, user:, num_stars: 1
    new_solution = create :concept_solution, user:, num_stars: 2

    assert_equal [new_solution, old_solution],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, :newest_first, nil, nil, nil)
  end

  test "fallback: sort most starred" do
    user = create :user
    solution_1 = create :concept_solution, user:, published_at: 2.weeks.ago, num_stars: 33
    solution_2 = create :concept_solution, user:, published_at: 3.weeks.ago, num_stars: 22
    solution_3 = create :concept_solution, user:, published_at: 1.week.ago, num_stars: 11

    assert_equal [solution_1, solution_2, solution_3],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, :most_starred, nil, nil, nil)
  end

  test "fallback: sort most starred by default" do
    user = create :user
    solution_1 = create :concept_solution, user:, published_at: 2.weeks.ago, num_stars: 33
    solution_2 = create :concept_solution, user:, published_at: 3.weeks.ago, num_stars: 22
    solution_3 = create :concept_solution, user:, published_at: 1.week.ago, num_stars: 11

    assert_equal [solution_1, solution_2, solution_3],
      Solution::SearchUserSolutions::Fallback.(user, 1, 15, nil, nil, nil, nil, nil, nil, nil, nil)
  end
end

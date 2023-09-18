require "test_helper"

class Exercise::UpdateMedianWaitTimesTest < ActiveSupport::TestCase
  test "update median time" do
    freeze_time do
      exercise = create :practice_exercise

      # Time between start request and discussion: 2 minutes
      solution_1 = create(:practice_solution, exercise:)
      request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 2.minutes
      create :mentor_discussion, request: request_1, created_at: Time.current

      Exercise::UpdateMedianWaitTimes.()

      assert_equal 120, exercise.reload.median_wait_time

      # Time between start request and discussion: 30 seconds
      solution_2 = create(:practice_solution, exercise:)
      request_2 = create :mentor_request, solution: solution_2, created_at: Time.current - 55.seconds
      create :mentor_discussion, request: request_2, created_at: Time.current - 25.seconds

      Exercise::UpdateMedianWaitTimes.()

      assert_equal 75, exercise.reload.median_wait_time

      # Time between start request and discussion: 3 hours
      solution_3 = create(:practice_solution, exercise:)
      request_3 = create :mentor_request, solution: solution_3, created_at: Time.current - 4.hours
      create :mentor_discussion, request: request_3, created_at: Time.current - 1.hour

      Exercise::UpdateMedianWaitTimes.()

      assert_equal 120, exercise.reload.median_wait_time
    end
  end

  test "discounts old discussions" do
    freeze_time do
      exercise = create :practice_exercise

      # Time between start request and discussion: 4 weeks and 2 hours
      solution_1 = create(:practice_solution, exercise:)
      request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 4.weeks - 2.hours
      create :mentor_discussion, request: request_1, created_at: Time.current - 4.weeks

      Exercise::UpdateMedianWaitTimes.()

      assert_nil exercise.reload.median_wait_time

      # Time between start request and discussion: 2 minutes
      solution_1 = create(:practice_solution, exercise:)
      request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 2.minutes
      create :mentor_discussion, request: request_1, created_at: Time.current

      Exercise::UpdateMedianWaitTimes.()

      assert_equal 120, exercise.reload.median_wait_time
    end
  end

  test "discounts discussions started directly after request" do
    freeze_time do
      exercise = create :practice_exercise

      # Sanity check
      Exercise::UpdateMedianWaitTimes.()

      assert_nil exercise.reload.median_wait_time

      # Time between start request and discussion less than 5 seconds
      solution_1 = create(:practice_solution, exercise:)
      request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 2.seconds
      create :mentor_discussion, request: request_1, created_at: Time.current

      Exercise::UpdateMedianWaitTimes.()

      assert_nil exercise.reload.median_wait_time

      # Time between start request and discussion: 2 minutes
      solution_1 = create(:practice_solution, exercise:)
      request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 2.minutes
      create :mentor_discussion, request: request_1, created_at: Time.current

      Exercise::UpdateMedianWaitTimes.()

      assert_equal 120, exercise.reload.median_wait_time
    end
  end

  test "set to nil when no solutions" do
    exercise = create :practice_exercise

    Exercise::UpdateMedianWaitTimes.()

    assert_nil exercise.reload.median_wait_time
  end

  test "set to nil when no requests" do
    exercise = create :practice_exercise
    create(:practice_solution, exercise:)
    create(:practice_solution, exercise:)

    Exercise::UpdateMedianWaitTimes.()

    assert_nil exercise.reload.median_wait_time
  end

  test "set to nil when no discussions" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)
    create(:mentor_request, solution:)
    create(:mentor_request, solution:)

    Exercise::UpdateMedianWaitTimes.()

    assert_nil exercise.reload.median_wait_time
  end

  test "only exercises with discussions have median wait time" do
    exercise_1 = create :practice_exercise
    exercise_2 = create :practice_exercise
    exercise_3 = create :practice_exercise
    solution_1 = create :practice_solution, exercise: exercise_1
    solution_2 = create :practice_solution, exercise: exercise_2
    create :practice_solution, exercise: exercise_3

    # Sanity check: exercises with no mentor requests
    assert_nil exercise_1.median_wait_time
    assert_nil exercise_2.median_wait_time
    assert_nil exercise_3.median_wait_time

    # Sanity check: exercises with mentor request but no discussion
    request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 21.minutes
    request_2 = create :mentor_request, solution: solution_2, created_at: Time.current - 33.minutes

    Exercise::UpdateMedianWaitTimes.()

    assert_nil exercise_1.reload.median_wait_time
    assert_nil exercise_2.reload.median_wait_time
    assert_nil exercise_3.reload.median_wait_time

    # Sanity check: one exercise with discussion
    create :mentor_discussion, request: request_1

    Exercise::UpdateMedianWaitTimes.()

    refute_nil exercise_1.reload.median_wait_time
    assert_nil exercise_2.reload.median_wait_time
    assert_nil exercise_3.reload.median_wait_time

    # Sanity check: two exercises with discussion
    create :mentor_discussion, request: request_2

    Exercise::UpdateMedianWaitTimes.()

    refute_nil exercise_1.reload.median_wait_time
    refute_nil exercise_2.reload.median_wait_time
    assert_nil exercise_3.reload.median_wait_time
  end

  test "shouldn't touch exercises's updated_at" do
    original_time = Time.current - 6.months
    exercise = create :practice_exercise, updated_at: original_time, median_wait_time: 100

    Track::UpdateMedianWaitTimes.()
    assert_equal original_time, exercise.reload.updated_at
  end
end

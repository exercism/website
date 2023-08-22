require "test_helper"

class Track::UpdateMedianWaitTimesTest < ActiveSupport::TestCase
  test "update median time" do
    freeze_time do
      track = create :track
      exercise = create(:practice_exercise, track:)

      # Time between start request and discussion: 2 minutes
      solution_1 = create(:practice_solution, exercise:)
      request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 2.minutes
      create :mentor_discussion, request: request_1, created_at: Time.current

      Track::UpdateMedianWaitTimes.()

      assert_equal 120, track.reload.median_wait_time

      # Time between start request and discussion: 30 seconds
      solution_2 = create(:practice_solution, exercise:)
      request_2 = create :mentor_request, solution: solution_2, created_at: Time.current - 55.seconds
      create :mentor_discussion, request: request_2, created_at: Time.current - 25.seconds

      Track::UpdateMedianWaitTimes.()

      assert_equal 75, track.reload.median_wait_time

      # Time between start request and discussion: 3 hours
      solution_3 = create(:practice_solution, exercise:)
      request_3 = create :mentor_request, solution: solution_3, created_at: Time.current - 4.hours
      create :mentor_discussion, request: request_3, created_at: Time.current - 1.hour

      Track::UpdateMedianWaitTimes.()

      assert_equal 120, track.reload.median_wait_time
    end
  end

  test "discounts old discussions" do
    freeze_time do
      track = create :track
      exercise = create(:practice_exercise, track:)

      # Time between start request and discussion: 4 weeks and 2 hours
      solution_1 = create(:practice_solution, exercise:)
      request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 4.weeks - 2.hours
      create :mentor_discussion, request: request_1, created_at: Time.current - 4.weeks

      Track::UpdateMedianWaitTimes.()

      assert_nil track.reload.median_wait_time

      # Time between start request and discussion: 3 hours
      solution_3 = create(:practice_solution, exercise:)
      request_3 = create :mentor_request, solution: solution_3, created_at: Time.current - 3.minutes
      create :mentor_discussion, request: request_3, created_at: Time.current

      Track::UpdateMedianWaitTimes.()

      assert_equal 180, track.reload.median_wait_time
    end
  end

  test "discounts discussions started directly after request" do
    freeze_time do
      track = create :track
      exercise = create(:practice_exercise, track:)

      # Sanity check
      Track::UpdateMedianWaitTimes.()

      assert_nil track.reload.median_wait_time

      # Time between start request and discussion: less than 5 seconds
      solution_2 = create(:practice_solution, exercise:)
      request_2 = create :mentor_request, solution: solution_2, created_at: Time.current - 2.seconds
      create :mentor_discussion, request: request_2, created_at: Time.current - 4.seconds

      Track::UpdateMedianWaitTimes.()

      assert_nil track.reload.median_wait_time

      # Time between start request and discussion: 3 minutes
      solution_3 = create(:practice_solution, exercise:)
      request_3 = create :mentor_request, solution: solution_3, created_at: Time.current - 3.minutes
      create :mentor_discussion, request: request_3, created_at: Time.current

      Track::UpdateMedianWaitTimes.()

      assert_equal 180, track.reload.median_wait_time
    end
  end

  test "set to nil when no solutions" do
    track = create :track

    Track::UpdateMedianWaitTimes.()

    assert_nil track.reload.median_wait_time
  end

  test "set to nil when no requests" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    create(:practice_solution, exercise:)
    create(:practice_solution, exercise:)

    Track::UpdateMedianWaitTimes.()

    assert_nil track.reload.median_wait_time
  end

  test "set to nil when no discussions" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    solution = create(:practice_solution, exercise:)
    create(:mentor_request, solution:)
    create(:mentor_request, solution:)

    Track::UpdateMedianWaitTimes.()

    assert_nil track.reload.median_wait_time
  end

  test "only exercises with discussions have median wait time" do
    track = create :track
    exercise_1 = create(:practice_exercise, track:)
    exercise_2 = create(:practice_exercise, track:)
    exercise_3 = create(:practice_exercise, track:)
    solution_1 = create :practice_solution, exercise: exercise_1
    solution_2 = create :practice_solution, exercise: exercise_2
    create :practice_solution, exercise: exercise_3

    # Sanity check: exercises with no mentor requests
    assert_nil track.median_wait_time

    # Sanity check: exercises with mentor request but no discussion
    request_1 = create :mentor_request, solution: solution_1, created_at: Time.current - 30.minutes
    request_2 = create :mentor_request, solution: solution_2, created_at: Time.current - 22.minutes

    Track::UpdateMedianWaitTimes.()

    assert_nil track.reload.median_wait_time

    # Sanity check: one exercise with discussion
    create :mentor_discussion, request: request_1

    Track::UpdateMedianWaitTimes.()

    refute_nil track.reload.median_wait_time

    # Sanity check: two exercises with discussion
    create :mentor_discussion, request: request_2

    Track::UpdateMedianWaitTimes.()

    refute_nil track.reload.median_wait_time
  end

  test "only takes into account own exercises" do
    freeze_time do
      track_1 = create :track, slug: 'ruby'
      track_2 = create :track, slug: 'fsharp'
      track_3 = create :track, slug: 'nim'
      exercise_1 = create :practice_exercise, track: track_1
      exercise_2 = create :practice_exercise, track: track_2
      exercise_3 = create :practice_exercise, track: track_3
      solution_1 = create :practice_solution, exercise: exercise_1
      solution_2 = create :practice_solution, exercise: exercise_2
      solution_3 = create :practice_solution, exercise: exercise_2
      solution_4 = create :practice_solution, exercise: exercise_3
      solution_5 = create :practice_solution, exercise: exercise_3

      # Sanity check: exercises with no mentor requests
      assert_nil track_1.median_wait_time
      assert_nil track_2.median_wait_time
      assert_nil track_3.median_wait_time

      Track::UpdateMedianWaitTimes.()

      # Sanity check: request without discussion
      create :mentor_request, solution: solution_1

      assert_nil track_1.reload.median_wait_time
      assert_nil track_2.reload.median_wait_time
      assert_nil track_3.reload.median_wait_time

      Track::UpdateMedianWaitTimes.()

      request_1 = create :mentor_request, solution: solution_1, exercise: solution_1.exercise, track: solution_1.track,
        created_at: Time.current - 18.minutes
      request_2 = create :mentor_request, solution: solution_2, exercise: solution_2.exercise, track: solution_2.track,
        created_at: Time.current - 50.minutes
      request_3 = create :mentor_request, solution: solution_3, exercise: solution_3.exercise, track: solution_3.track,
        created_at: Time.current - 90.minutes
      request_4 = create :mentor_request, solution: solution_3, exercise: solution_3.exercise, track: solution_3.track,
        created_at: Time.current - 5.minutes
      request_5 = create :mentor_request, solution: solution_4, exercise: solution_4.exercise, track: solution_4.track,
        created_at: Time.current - 19.minutes
      request_6 = create :mentor_request, solution: solution_5, exercise: solution_5.exercise, track: solution_5.track,
        created_at: Time.current - 31.minutes
      create :mentor_discussion, request: request_1, solution: request_1.solution, track: request_1.track,
        created_at: Time.current - 11.minutes
      create :mentor_discussion, request: request_2, solution: request_2.solution, track: request_2.track,
        created_at: Time.current - 22.minutes
      create :mentor_discussion, request: request_3, solution: request_3.solution, track: request_3.track,
        created_at: Time.current - 33.minutes
      create :mentor_discussion, request: request_4, solution: request_4.solution, track: request_4.track,
        created_at: Time.current - 2.minutes
      create :mentor_discussion, request: request_5, solution: request_5.solution, track: request_5.track,
        created_at: Time.current - 16.minutes
      create :mentor_discussion, request: request_6, solution: request_6.solution, track: request_6.track,
        created_at: Time.current - 29.minutes

      Track::UpdateMedianWaitTimes.()

      assert_equal 420, track_1.reload.median_wait_time
      assert_equal 1680, track_2.reload.median_wait_time
      assert_equal 150, track_3.reload.median_wait_time
    end
  end

  test "shouldn't touch track's updated_at" do
    original_time = Time.current - 6.months
    track = create :track, updated_at: original_time, median_wait_time: 100

    Track::UpdateMedianWaitTimes.()
    assert_equal original_time, track.reload.updated_at
  end
end

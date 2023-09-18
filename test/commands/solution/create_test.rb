require "test_helper"

class Solution::CreateTest < ActiveSupport::TestCase
  test "raises unless exercise is unlocked" do
    ex = create :concept_exercise
    ut = create :user_track, track: ex.track
    UserTrack.any_instance.expects(:exercise_unlocked?).with(ex).returns(false)

    assert_raises ExerciseLockedError do
      Solution::Create.(ut.user, ex)
    end
  end

  test "creates concept_solution" do
    ex = create :concept_exercise
    ut = create :user_track, track: ex.track
    UserTrack.any_instance.expects(:exercise_unlocked?).with(ex).returns(true)

    solution = Solution::Create.(ut.user, ex)
    assert solution.is_a?(ConceptSolution)
    assert_equal ut.user, solution.user
    assert_equal ex, solution.exercise
  end

  test "creates practice_solution" do
    ex = create :practice_exercise
    ut = create :user_track, track: ex.track
    UserTrack.any_instance.expects(:exercise_unlocked?).with(ex).returns(true)

    solution = Solution::Create.(ut.user, ex)
    assert solution.is_a?(PracticeSolution)
    assert_equal ut.user, solution.user
    assert_equal ex, solution.exercise
  end

  test "idempotent" do
    user = create :user
    ex = create :concept_exercise
    ut = create :user_track, user:, track: ex.track
    UserTrack.any_instance.expects(:exercise_unlocked?).with(ex).returns(true).twice

    assert_idempotent_command { Solution::Create.(ut.user, ex) }
  end

  test "creates activity" do
    user = create :user
    exercise = create :concept_exercise
    ut = create :user_track, user:, track: exercise.track
    create :hello_world_solution, :completed, track: ut.track, user: ut.user

    solution = Solution::Create.(ut.user, exercise)

    activity = User::Activities::StartedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end

  test "does not create activity if not new" do
    user = create :user
    exercise = create :concept_exercise
    ut = create :user_track, user:, track: exercise.track
    create :hello_world_solution, :completed, track: ut.track, user: ut.user
    create(:concept_solution, exercise:, user:)

    Solution::Create.(ut.user, exercise)

    refute User::Activities::StartedExerciseActivity.exists?
  end

  test "adds metric" do
    track = create :track
    user = create :user
    ex = create(:concept_exercise, track:)
    create(:user_track, track:, user:)
    UserTrack.any_instance.expects(:exercise_unlocked?).with(ex).returns(true)

    solution = Solution::Create.(user, ex)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::StartSolutionMetric, metric
    assert_equal solution.created_at, metric.occurred_at
    assert_equal solution, metric.solution
    assert_equal track, metric.track
    assert_equal user, metric.user
  end
end

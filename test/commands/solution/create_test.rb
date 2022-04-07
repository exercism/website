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
    ut = create :user_track, user: user, track: ex.track
    UserTrack.any_instance.expects(:exercise_unlocked?).with(ex).returns(true).twice

    assert_idempotent_command { Solution::Create.(ut.user, ex) }
  end

  test "creates activity" do
    user = create :user
    exercise = create :concept_exercise
    ut = create :user_track, user: user, track: exercise.track
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
    ut = create :user_track, user: user, track: exercise.track
    create :hello_world_solution, :completed, track: ut.track, user: ut.user
    create :concept_solution, exercise: exercise, user: user

    Solution::Create.(ut.user, exercise)

    refute User::Activities::StartedExerciseActivity.exists?
  end

  test "awards new years resolution badge when submitted on January 1st" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    create :hello_world_solution, :completed, track: track, user: user
    refute user.badges.present?

    perform_enqueued_jobs do
      # Solution submitted on 31st of December
      travel_to(Time.utc(2018, 12, 31, 23, 59, 59))
      exercise_1 = create :concept_exercise, slug: 'exercise_1'
      Solution::Create.(user, exercise_1)
      refute user.badges.present?

      # Solution submitted on 2st of January
      travel_to(Time.utc(2019, 1, 2, 0, 0, 0))
      exercise_2 = create :concept_exercise, slug: 'exercise_2'
      Solution::Create.(user, exercise_2)
      refute user.badges.present?

      # Solution submitted on 1st of January
      travel_to(Time.utc(2019, 1, 1, 0, 0, 0))
      exercise_3 = create :concept_exercise, slug: 'exercise_3'
      Solution::Create.(user, exercise_3)
      assert_includes user.reload.badges.map(&:class), Badges::NewYearsResolutionBadge
    end
  end
end

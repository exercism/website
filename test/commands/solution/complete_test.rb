require "test_helper"

class Solution::CompleteTest < ActiveSupport::TestCase
  test "sets concept exercise solution as completed" do
    exercise = create :concept_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :concept_solution, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track)

    assert solution.reload.completed?
  end

  test "sets concept exercise concepts as learnt" do
    track = create :track
    concept = create :concept, track: track
    exercise = create :concept_exercise, track: track
    exercise.taught_concepts << concept

    user = create :user
    user_track = create :user_track, user: user, track: track
    solution = create :concept_solution, user: user, exercise: exercise
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    Solution::Complete.(solution, user_track)

    assert user_track.concept_learnt?(concept)
  end

  test "sets practice exercise solution as completed" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track)

    assert solution.reload.completed?
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track)

    activity = User::Activities::CompletedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end

  test "does nothing when solution has already been completed" do
    freeze_time do
      exercise = create :concept_exercise
      completed_at = Time.current - 5.minutes

      user = create :user
      user_track = create :user_track, user: user, track: exercise.track
      solution = create :concept_solution, user: user, exercise: exercise, completed_at: completed_at
      create :iteration, solution: solution

      # Sanity check
      assert solution.completed?

      Solution::Complete.(solution, user_track)

      solution.reload
      assert solution.completed?
      assert_equal completed_at, solution.completed_at
      refute User::Activities::CompletedExerciseActivity.exists?
    end
  end

  test "raises when solution has no iterations" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise

    assert_raises SolutionHasNoIterationsError do
      Solution::Complete.(solution, user_track)
    end
  end
end

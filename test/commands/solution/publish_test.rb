require "test_helper"

class Solution::PublishTest < ActiveSupport::TestCase
  test "sets solution and iteration as published" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, solution.user_track, 1)

    assert solution.reload.published?
    assert iteration.reload.published?
    refute other_iteration.reload.published?
  end

  test "all iterations are published if none are passed" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, solution.user_track, nil)

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "all iterations are published if incorrect is passed" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, solution.user_track, 5)

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "only does things once" do
    solution = create :practice_solution
    create :iteration, solution: solution

    AwardReputationTokenJob.expects(:perform_later).once
    Solution::Publish.(solution, solution.user_track, nil)
    Solution::Publish.(solution, solution.user_track, nil)
  end

  test "does not award for concept exercises" do
    practice_solution = create :practice_solution
    concept_solution = create :concept_solution
    create :iteration, solution: practice_solution
    create :iteration, solution: concept_solution

    AwardReputationTokenJob.expects(:perform_later).once
    Solution::Publish.(practice_solution, practice_solution.user_track, nil)

    AwardReputationTokenJob.expects(:perform_later).never
    Solution::Publish.(concept_solution, practice_solution.user_track, nil)
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    iteration = create :iteration, solution: solution

    Solution::Publish.(solution, solution.user_track, iteration.idx)

    activity = User::Activities::PublishedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end

  test "completes solution if not completed" do
    freeze_time do
      solution = create :practice_solution, completed_at: nil
      create :iteration, solution: solution, idx: 1

      Solution::Publish.(solution, solution.user_track, 1)

      assert_equal Time.current, solution.reload.completed_at
    end
  end
end

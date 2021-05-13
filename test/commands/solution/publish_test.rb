require "test_helper"

class Solution::PublishTest < ActiveSupport::TestCase
  test "sets solution and iteration as published" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, 1)

    assert solution.reload.published?
    assert iteration.reload.published?
    refute other_iteration.reload.published?
  end

  test "all iterations are published if none are passed" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, nil)

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "all iterations are published if incorrect is passed" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, 5)

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "only does things once" do
    solution = create :practice_solution
    create :iteration, solution: solution

    AwardReputationTokenJob.expects(:perform_later).once
    Solution::Publish.(solution, nil)
    Solution::Publish.(solution, nil)
  end

  test "does not award for concept exercises" do
    practice_solution = create :practice_solution
    concept_solution = create :concept_solution
    create :iteration, solution: practice_solution
    create :iteration, solution: concept_solution

    AwardReputationTokenJob.expects(:perform_later).once
    Solution::Publish.(practice_solution, nil)

    AwardReputationTokenJob.expects(:perform_later).never
    Solution::Publish.(concept_solution, nil)
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    iteration = create :iteration, solution: solution

    Solution::Publish.(solution, iteration.idx)

    activity = User::Activities::PublishedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end
end

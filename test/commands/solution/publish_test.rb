require "test_helper"

class Solution::PublishTest < ActiveSupport::TestCase
  test "sets solution and iteration as published" do
    solution = create :practice_solution
    iteration = create :iteration, solution: solution

    Solution::Publish.(solution, [iteration.idx])

    assert solution.reload.published?
    assert iteration.reload.published?
  end

  test "sets correct iterations as published" do
    solution = create :practice_solution
    iteration_1 = create :iteration, solution: solution, idx: 1
    iteration_2 = create :iteration, solution: solution, idx: 2
    iteration_3 = create :iteration, solution: solution, idx: 3

    Solution::Publish.(solution, [iteration_1.idx, iteration_3.idx])

    assert solution.reload.published?
    assert iteration_1.reload.published?
    refute iteration_2.reload.published?
    assert iteration_3.reload.published?
  end

  test "defaults to last iteration with no iterations" do
    solution = create :practice_solution
    iteration_1 = create :iteration, solution: solution, idx: 1
    iteration_2 = create :iteration, solution: solution, idx: 2
    iteration_3 = create :iteration, solution: solution, idx: 3

    Solution::Publish.(solution, [])

    assert solution.reload.published?
    refute iteration_1.reload.published?
    refute iteration_2.reload.published?
    assert iteration_3.reload.published?
  end

  test "defaults to last iteration with incorrect iterations" do
    solution = create :practice_solution
    iteration_1 = create :iteration, solution: solution, idx: 1
    iteration_2 = create :iteration, solution: solution, idx: 2
    iteration_3 = create :iteration, solution: solution, idx: 3

    Solution::Publish.(solution, [5])

    assert solution.reload.published?
    refute iteration_1.reload.published?
    refute iteration_2.reload.published?
    assert iteration_3.reload.published?
  end

  test "only does things once" do
    solution = create :practice_solution
    create :iteration, solution: solution

    AwardReputationTokenJob.expects(:perform_later).once
    Solution::Publish.(solution, [5])
    Solution::Publish.(solution, [5])
  end

  test "does not award for concept exercises" do
    practice_solution = create :practice_solution
    concept_solution = create :concept_solution
    create :iteration, solution: practice_solution
    create :iteration, solution: concept_solution

    AwardReputationTokenJob.expects(:perform_later).once
    Solution::Publish.(practice_solution, [5])

    AwardReputationTokenJob.expects(:perform_later).never
    Solution::Publish.(concept_solution, [5])
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    iteration = create :iteration, solution: solution

    Solution::Publish.(solution, [iteration.id])

    activity = User::Activities::PublishedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end
end

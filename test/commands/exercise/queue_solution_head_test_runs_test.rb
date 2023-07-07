require "test_helper"

class Exercise::QueueSolutionHeadTestRunsTest < ActiveSupport::TestCase
  test "queues published solutions" do
    exercise = create :practice_exercise, git_sha: '0b04b8976650d993ecf4603cf7413f3c6b898eff'
    solution_1 = create(:practice_solution, :published, exercise:)
    solution_2 = create(:practice_solution, :published, exercise:)

    Solution::QueueHeadTestRun.expects(:call).with(solution_1)
    Solution::QueueHeadTestRun.expects(:call).with(solution_2)

    Exercise::QueueSolutionHeadTestRuns.(exercise)
  end

  test "does not queue unpublished solutions" do
    exercise = create :practice_exercise, git_sha: '0b04b8976650d993ecf4603cf7413f3c6b898eff'
    solution_1 = create(:practice_solution, exercise:)
    solution_2 = create(:practice_solution, exercise:)

    Solution::QueueHeadTestRun.expects(:call).with(solution_1).never
    Solution::QueueHeadTestRun.expects(:call).with(solution_2).never

    Exercise::QueueSolutionHeadTestRuns.(exercise)
  end

  test "does not queue solutions when exercise's synced commit contains magic marker" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'
    solution_1 = create(:practice_solution, :published, exercise:)
    solution_2 = create(:practice_solution, :published, exercise:)

    Solution::QueueHeadTestRun.expects(:call).with(solution_1).never
    Solution::QueueHeadTestRun.expects(:call).with(solution_2).never

    Exercise::QueueSolutionHeadTestRuns.(exercise)
  end
end

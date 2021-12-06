require "test_helper"

class Solution::QueueHeadTestRunTest < ActiveSupport::TestCase
  test "inits test run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "does not inits if there's a head run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission

    Submission::TestRun::Init.expects(:call).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "inits if there's not a head run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission, git_important_files_hash: "foobar"

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end
end

require "test_helper"

class Solution::UpdateToLatestExerciseVersionTest < ActiveSupport::TestCase
  test "updates git data" do
    solution = create :concept_solution
    solution.update!(git_sha: "foo", git_slug: "bar")

    # Sanity
    assert_equal "foo", solution.git_sha
    assert_equal "bar", solution.git_slug

    Solution::UpdateToLatestExerciseVersion.(solution)
    assert_equal solution.exercise.git_sha, solution.git_sha
    assert_equal solution.exercise.slug, solution.git_slug
    assert_equal solution.exercise.git_important_files_hash, solution.git_important_files_hash
  end

  test "updates last iteration submission's git data" do
    solution = create :concept_solution
    old_submission = create(:iteration, solution:).submission
    new_submission = create(:iteration, solution:).submission
    deleted_submission = create(:iteration, solution:, deleted_at: Time.current).submission

    [old_submission, new_submission, deleted_submission].each do |submission|
      submission.update!(git_sha: "foo", git_slug: "bar")

      # Sanity
      assert_equal "foo", submission.git_sha
      assert_equal "bar", submission.git_slug
    end

    Solution::UpdateToLatestExerciseVersion.(solution)
    [old_submission, new_submission, deleted_submission].each(&:reload)

    assert_equal "foo", old_submission.git_sha
    assert_equal "bar", old_submission.git_slug
    assert_equal solution.exercise.git_sha, new_submission.git_sha
    assert_equal solution.exercise.slug, new_submission.git_slug
    assert_equal "foo", deleted_submission.git_sha
    assert_equal "bar", deleted_submission.git_slug
  end

  test "reruns test on latest iteration's submission" do
    solution = create :concept_solution
    create(:iteration, solution:).submission
    new_submission = create(:iteration, solution:).submission
    create(:iteration, solution:, deleted_at: Time.current).submission

    Submission::TestRun::Init.expects(:call).with(new_submission, run_in_background: true)

    Solution::UpdateToLatestExerciseVersion.(solution)
  end

  test "don't rerun test if test runner is disabled" do
    solution = create :concept_solution
    solution.exercise.update(has_test_runner: false)
    create(:iteration, solution:).submission
    create(:iteration, solution:).submission
    create(:iteration, solution:, deleted_at: Time.current).submission

    Submission::TestRun::Init.expects(:call).never

    Solution::UpdateToLatestExerciseVersion.(solution)
  end
end

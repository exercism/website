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
    exercise = create :concept_exercise, representer_version: 20
    solution = create(:concept_solution, exercise:)
    old_submission = create(:iteration, solution:).submission
    new_submission = create(:iteration, solution:).submission
    deleted_submission = create(:iteration, solution:, deleted_at: Time.current).submission

    [old_submission, new_submission, deleted_submission].each do |submission|
      submission.update!(git_sha: "foo", git_slug: "bar", git_important_files_hash: "gifh", exercise_representer_version: 13)

      # Sanity
      assert_equal "foo", submission.git_sha
      assert_equal "bar", submission.git_slug
    end

    Solution::UpdateToLatestExerciseVersion.(solution)
    [old_submission, new_submission, deleted_submission].each(&:reload)

    assert_equal solution.exercise.git_sha, new_submission.git_sha
    assert_equal solution.exercise.slug, new_submission.git_slug
    assert_equal solution.git_important_files_hash, new_submission.git_important_files_hash
    assert_equal exercise.representer_version, new_submission.exercise_representer_version

    # Other things are unchanged
    [old_submission, deleted_submission].each do |sub|
      assert_equal "foo", sub.git_sha
      assert_equal "bar", sub.git_slug
      assert_equal "gifh", sub.git_important_files_hash
      assert_equal 13, sub.exercise_representer_version
    end
  end

  test "reruns test on latest iteration's submission" do
    solution = create :concept_solution
    create(:iteration, solution:).submission
    new_submission = create(:iteration, solution:).submission
    create(:iteration, solution:, deleted_at: Time.current).submission

    Submission::TestRun::Init.expects(:call).with(new_submission, run_in_background: true)

    Solution::UpdateToLatestExerciseVersion.(solution)
  end

  test "reruns representation on latest iteration's submission" do
    solution = create :concept_solution
    create(:iteration, solution:).submission
    new_submission = create(:iteration, solution:).submission
    create(:iteration, solution:, deleted_at: Time.current).submission

    Submission::Representation::Init.expects(:call).with(new_submission, run_in_background: true)

    Solution::UpdateToLatestExerciseVersion.(solution)
  end

  test "updates solution's published exercise representation" do
    solution = create :concept_solution

    Solution::UpdatePublishedExerciseRepresentation.expects(:defer).with(solution, wait: 10)

    Solution::UpdateToLatestExerciseVersion.(solution)
  end
end

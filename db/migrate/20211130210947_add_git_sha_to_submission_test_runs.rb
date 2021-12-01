class AddGitShaToSubmissionTestRuns < ActiveRecord::Migration[6.1]
  def up
    execute "ALTER TABLE `submissions` ADD `git_important_files_hash` varchar(50) NULL, ALGORITHM=INPLACE, LOCK=NONE"

    execute "ALTER TABLE `submission_test_runs` ADD `git_important_files_hash` varchar(50) NULL, ALGORITHM=INPLACE, LOCK=NONE"
    execute "ALTER TABLE `submission_test_runs` ADD `git_sha` varchar(50) NULL, ALGORITHM=INPLACE, LOCK=NONE"

    return

    # Run the following to set the git_important_files_hash on all submissions
    ActiveRecord::Base.transaction(isolation: Exercism::READ_UNCOMMITTED) do
      submissions = Submission.joins(:solution).includes(solution: :exercise).
        select(:id, :git_sha, :solution_id, :exercise_id).
        group_by(&:git_sha)

      submissions.each do |git_sha, group|
        exercise = group.first.exercise
        new_hash = Git::GenerateHashForImportantExerciseFiles.(exercise, git_sha: git_sha)
        group.each do |submission|
          submission.update_column(:git_important_files_hash, new_hash)
        end
      end
    end

    # Run the following to set the git_shas on all submission_test_runs
    ActiveRecord::Base.transaction(isolation: Exercism::READ_UNCOMMITTED) do
      Submission::TestRun.joins(submission: :solution).update_all("submission_test_runs.git_sha = submissions.git_sha")
    end

    # Run the following to set the git_important_files_hash on all submission_test_runs
    ActiveRecord::Base.transaction(isolation: Exercism::READ_UNCOMMITTED) do
      test_runs = Submission::TestRun.joins(submission: :solution).includes(submission: {solution: :exercise}).
        select(:id, :git_sha, :submission_id, :solution_id, :exercise_id).
        group_by(&:git_sha)

      test_runs.each do |git_sha, group|
        exercise = group.first.submission.exercise
        new_hash = Git::GenerateHashForImportantExerciseFiles.(exercise, git_sha: git_sha)
        group.each do |test_run|
          test_run.update_column(:git_important_files_hash, new_hash)
        end
      end
    end
  end

  def down
    remove_column :submissions, :git_important_files_hash

    remove_column :submission_test_runs, :git_sha
    remove_column :submission_test_runs, :git_important_files_hash
  end
end

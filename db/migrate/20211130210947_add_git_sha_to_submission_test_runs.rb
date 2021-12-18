class AddGitShaToSubmissionTestRuns < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TABLE `submissions` ADD `git_important_files_hash` varchar(50) NULL, ALGORITHM=INPLACE, LOCK=NONE"

    execute "ALTER TABLE `submission_test_runs` ADD `git_important_files_hash` varchar(50) NULL, ALGORITHM=INPLACE, LOCK=NONE"
    execute "ALTER TABLE `submission_test_runs` ADD `git_sha` varchar(50) NULL, ALGORITHM=INPLACE, LOCK=NONE"

    return

    Exercise.all.find_each do |exercise|
      next if exercise.track_id == 31
      next if exercise.slug.starts_with?('legacy')

      ActiveRecord::Base.transaction(isolation: Exercism::READ_UNCOMMITTED) do
        Submission.joins(:solution).includes(:solution).
          where(git_sha: "").
          where("solution.exercise_id": exercise.id).
          update_all('submissions.git_sha = solution.git_sha')
      end
    end

    # Run the following to set the git_important_files_hash on all submissions
    Exercise.all.find_each do |exercise|
      next if exercise.track_id == 31
      next if exercise.slug.starts_with?('legacy')

      submissions = Submission.joins(:solution).includes(solution: :exercise).
        where(git_important_files_hash: nil).
        where.not(git_sha: "").
        where("solution.exercise_id": exercise.id).
        select(:id, :git_sha, :solution_id, :exercise_id).
        group_by(&:git_sha);0

      submissions.each do |git_sha, group|
        new_hash = Git::GenerateHashForImportantExerciseFiles.(group.first.exercise, git_sha: git_sha)
        group.in_groups_of(100, false).each do |subgroup|
          ActiveRecord::Base.transaction(isolation: Exercism::READ_UNCOMMITTED) do
            Submission.where(id: subgroup.map(&:id)).update_all("submissions.git_important_files_hash = '#{new_hash}'")
          end
        end
      rescue
      end
    end

     # Run the following to set the git_shas on all submission_test_runs
    Exercise.all.find_each do |exercise|
      next if exercise.track_id == 31
      next if exercise.slug.starts_with?('legacy')

      ActiveRecord::Base.transaction(isolation: Exercism::READ_UNCOMMITTED) do
        Submission::TestRun.joins(submission: :solution).
          where(git_sha: nil).
          where('solutions.exercise_id': exercise.id).
          update_all("submission_test_runs.git_sha = submissions.git_sha, submission_test_runs.git_important_files_hash = submissions.git_important_files_hash")
      end
    end

    # # Run the following to set the git_important_files_hash on all submission_test_runs
    # Exercise.all.find_each do |exercise|
    #   next if exercise.track_id == 31
    #   next if exercise.slug.starts_with?('legacy')

    #   test_runs = Submission::TestRun.joins(submission: :solution).includes(submission: {solution: :exercise}).
    #     where(git_important_files_hash: nil).
    #     select(:id, :git_sha, :submission_id, :solution_id, :exercise_id).
    #     group_by(&:git_sha)

    #   test_runs.each do |git_sha, group|
    #     exercise = group.first.submission.exercise
    #     new_hash = Git::GenerateHashForImportantExerciseFiles.(exercise, git_sha: git_sha)
    #     group.each do |test_run|
    #       test_run.update_column(:git_important_files_hash, new_hash)
    #     end
    #   end
    # end
  end

  def down
    remove_column :submissions, :git_important_files_hash

    remove_column :submission_test_runs, :git_sha
    remove_column :submission_test_runs, :git_important_files_hash
  end
end

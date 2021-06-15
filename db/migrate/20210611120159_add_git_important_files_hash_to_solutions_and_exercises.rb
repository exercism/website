class AddGitImportantFilesHashToSolutionsAndExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :git_important_files_hash, :string, null: true
    add_column :exercises, :git_important_files_hash, :string, null: true

    Exercise.find_each do |exercise|
      exercise.update!(git_important_files_hash: Git::GenerateHashForImportantExerciseFiles.(exercise))
    end

    Solution.joins(:exercise).update_all(
      "solutions.git_slug = exercises.slug,
       solutions.git_sha = exercises.git_sha,
       solutions.git_important_files_hash = exercises.git_important_files_hash")

    change_column_null :solutions, :git_important_files_hash, :false
    change_column_null :exercises, :git_important_files_hash, :false
  end
end
